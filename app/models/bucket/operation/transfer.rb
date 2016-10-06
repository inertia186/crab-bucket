module Bucket
  class Operation::Transfer < Bucket::Operation
    scope :amount, lambda { |amount, options = {}|
      transfer = Transfer.arel_table
      r = where(
        transfer[:payload].matches(
          "%\"amount\":\"#{('%.3f' % amount.to_f)} SBD\"%"
        )
      )
      r = r.or(
        where(
          transfer[:payload].matches(
            "%\"amount\":\"#{('%.3f' % amount.to_f)} STEEM\"%"
          )
        )
      )
      
      r.tap do |r|
        return !!options[:invert] ? where.not(id: r.select(:id)) : r
      end
    }
    
    scope :memo, lambda { |memo, options = {}|
      transfer = Transfer.arel_table
      query_string = "%\"memo\":\"#{memo}\"%"
      
      where(transfer[:payload].matches(query_string)).tap do |r|
        return !!options[:invert] ? where.not(id: r.select(:id)) : r
      end
    }
  end
end
