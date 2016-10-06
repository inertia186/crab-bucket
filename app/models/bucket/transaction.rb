module Bucket
  class Transaction < ApplicationRecord
    belongs_to :block
    has_many :operations, dependent: :destroy
    
    scope :query, lambda { |query, invert = false|
      where(id: Operation.query(query, invert).select(:transaction_id))
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
