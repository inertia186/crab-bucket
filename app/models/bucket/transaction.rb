module Bucket
  class Transaction < ApplicationRecord
    belongs_to :block
    has_many :operations, dependent: :destroy
    
    scope :query, lambda { |query, options = {}|
      where(id: Operation.query(query, options).select(:transaction_id))
    }
    
    scope :has_operation_type, lambda { |operation_type, options = {}|
      where(id: Operation.where(type: operation_type).select(:transaction_id))
    }
    
    # Records transactions as ActiveRecord entries.
    def self.record(block, transactions)
      [transactions].flatten.each do |transaction|
        params = {
          block: block,
          ref_block_num: transaction.ref_block_num,
          ref_block_prefix: transaction.ref_block_prefix,
          expiration: Time.parse(transaction.expiration + ' UTC')
        }
        
        _transaction = Transaction.create(params)
        if _transaction.persisted?
          _transaction.operations.record(_transaction, transaction.operations)
        end
      end
    end
  end
end
