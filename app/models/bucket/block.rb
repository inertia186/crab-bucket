module Bucket
  class Block < ApplicationRecord
    has_many :transactions, dependent: :destroy
    has_many :operations, through: :transactions
    has_many :virtual_operations, conditions: { 'transaction_id = NULL' }

    validates :block_number, numericality: true, presence: true, uniqueness: true
  
    scope :ordered, lambda { |options = {}|
      sort_field = options[:sort_field].presence || :block_number
      sort_order = options[:sort_order].presence || :asc
      
      order(sort_field => sort_order)
    }
    
    scope :witness, lambda { |witness, options = {}|
      where(witness: witness).tap do |r|
        return !!options[:invert] ? where.not(id: r.select(:id)) : r
      end
    }
    
    scope :query, lambda { |query, options = {}|
      op = Operation.query(query, options).select(:transaction_id)
      where(id: Transaction.where(id: op).select(:block_id))
    }
    
    scope :has_operation_type, lambda { |operation_type, options = {}|
      op = Operation.where(type: operation_type).select(:transaction_id)
      where(id: Transaction.where(id: op).select(:block_id))
    }
    
    # Rebuild will look for any missing blocks.  Could use a lot of memory if
    # there are large gaps.  It is recommended to call #replay! if your database
    # is just behind the head block with no gaps.
    def self.rebuild!(&block)
      block_numbers = Block.pluck(:block_number)
      properties = Bucket.api.get_dynamic_global_properties.result
      head_block_number = properties.head_block_number
      block_numbers = [*(1..head_block_number)] - block_numbers
      
      Bucket.api.get_blocks(block_numbers) do |_block, number|
        __block = Block.record(_block, number)

        if !!block
          yield __block
        else
          __block
        end
      end
    end
    
    # Replay will pick up where the last block left off.
    #
    # If block number is provided as an argument, replay will pick up from that
    # block number.
    #
    # If a duration is provided as an argument, replay will pick up from the
    # block number estimated to be that long ago.
    # 
    # @param from [Fixnum | ActiveSupport::Duration] a block number or duration to start from, optional.
    def self.replay!(from = nil, &block)
      from_block_number = if from.class.ancestors.include? ActiveSupport::Duration
        estimate_block_number(from)
      else
        from
      end
      
      latest_block_number = Block.maximum(:block_number).to_i
      current_block_number = from_block_number || latest_block_number + 1
      properties = Bucket.api.get_dynamic_global_properties.result
      head_block_number = properties.head_block_number
      
      Bucket.api.get_blocks(current_block_number..head_block_number) do |_block, number|
        __block = Block.record(_block, number)

        if !!block
          yield __block
        else
          __block
        end
      end
    end
    
    # Stream the current block as it appears in the blockchain.
    # 
    def self.stream_head!(&block)
      Bucket.stream.block_numbers do |number|
        raw_block = Bucket.api.find_block(number)
        redo if raw_block.nil?
        
        _block = Block.record(raw_block, number)
        
        if !!block
          yield _block
        else
          _block
        end
      end
    end
    
    # Records a block as an ActiveRecord entries.
    # 
    # @param block [Hash] the block that came from the blockchain
    # @param number [Fixnum] the block number
    def self.record(block, number)
      params = {
        block_number: number,
        previous: block.previous,
        timestamp: Time.parse(block.timestamp + ' UTC'),
        transaction_merkle_root: block.transaction_merkle_root,
        witness: block.witness,
        witness_signature: block.witness_signature
      }
      _block = nil
      
      ActiveRecord::Base.transaction do
        _block = Block.create(params)
        if _block.persisted?
          _block.transactions.record(_block, block.transactions)
          _block.virtual_operations.record(_block, block.virtaul_operations)
        end
      end
      
      _block
    end
    
    def self.estimate_block_number(subtract)
      properties = Bucket.api.get_dynamic_global_properties.result
      head_block_number = properties.head_block_number
      
      [head_block_number - (subtract.seconds / 3), 0].max
    end
  end
end
