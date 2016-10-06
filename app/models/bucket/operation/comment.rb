module Bucket
  class Operation::Comment < Bucket::Operation
    scope :author, lambda { |author, options = {}|
      comment = Comment.arel_table
      query_string = "%\"author\":\"#{author}\"%"
      
      where(comment[:payload].matches(query_string)).tap do |r|
        return !!options[:invert] ? where.not(id: r.select(:id)) : r
      end
    }
  end
end
