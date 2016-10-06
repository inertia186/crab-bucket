module Bucket
  class Operation < ApplicationRecord
    # Note, ActiveRecord is already using a method named 'transactions'. To
    # handle this issue, we're choosing an appropriate alternative name for the
    # association and specify the model class and foreign key manually.
    belongs_to :block_transaction, foreign_key: 'transaction_id',
      class_name: 'Transaction'
    delegate :block, to: :block_transaction
    
    scope :pow, -> { where(type: 'Bucket::Operation::Pow') }
    scope :pow2, -> { where(type: 'Bucket::Operation::Pow2') }
    scope :vote, -> { where(type: 'Bucket::Operation::Vote') }
    scope :comment, -> { where(type: 'Bucket::Operation::Comment') }
    scope :feed_publish, -> { where(type: 'Bucket::Operation::FeedPublish') }
    scope :account_create, -> { where(type: 'Bucket::Operation::AccountCreate') }
    scope :account_update, -> { where(type: 'Bucket::Operation::AccountUpdate') }
    scope :limit_order_create, -> { where(type: 'Bucket::Operation::LimitOrderCreate') }
    scope :limit_order_cancel, -> { where(type: 'Bucket::Operation::LimitOrderCancel') }
    scope :custom_json, -> { where(type: 'Bucket::Operation::CustomJson') }
    scope :transfer, -> { where(type: 'Bucket::Operation::Transfer') }
    scope :comment_option, -> { where(type: 'Bucket::Operation::CommentOption') }
    scope :convert, -> { where(type: 'Bucket::Operation::Convert') }
    scope :transfer_to_vesting, -> { where(type: 'Bucket::Operation::TransferToVesting') }
    scope :account_witness_vote, -> { where(type: 'Bucket::Operation::AccountWitnessVote') }
    scope :delete_comment, -> { where(type: 'Bucket::Operation::DeleteComment') }
    scope :witness_update, -> { where(type: 'Bucket::Operation::WitnessUpdate') }
    
    scope :query, lambda { |query, invert = false|
      operation = Operation.arel_table
      query_string = "%#{query}%"
      
      where(operation[:payload].matches(query_string)).tap do |r|
        return invert ? where.not(id: r.select(:id)) : r
      end
    }

    # Records a operation as ActiveRecord entries.
    def self.record(transaction, operations)
      operations.each do |operation|
        params = {
          block_transaction: transaction,
          type: "Bucket::Operation::#{operation.first.classify}",
          payload: operation.last.to_json,
        }
        
        Operation.create(params)
      end
    end
    
    def steem_type
      type.split(/::/).last.underscore
    end
    
    def respond_to_missing?(m, include_private = false)
      payload.respond_to? m
    end

    def method_missing(m, *args, &block)
      super unless respond_to_missing?(m)
      
      payload[m.to_sym]
    end
    
    def payload
      @payload ||= Hashie::Mash.new(JSON[read_attribute(:payload)])
    end
  end
end
