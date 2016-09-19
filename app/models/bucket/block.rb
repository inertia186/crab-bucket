module Bucket
  class Block < ApplicationRecord
    has_many :transactions, dependent: :destroy
    has_many :operations, through: :transactions

    validates_uniqueness_of :block_number
    
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
    # @param from_block_number [Fixnum] a block number to start from, optional.
    def self.replay!(from_block_number = nil, &block)
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
        _block = Block.record(Bucket.api.find_block(number), number)
        
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
        end
      end
      
      _block
    end
  end
end
