module Bucket
  class Operation::CustomJson < Bucket::Operation
    scope :sub_type, lambda { |sub_type, options = {}|
      custom_json = CustomJson.arel_table
      query_string = "%\"id\":\"#{sub_type}\"%"
      
      where(custom_json[:payload].matches(query_string)).tap do |r|
        return !!options[:invert] ? where.not(id: r.select(:id)) : r
      end
    }
    
    def json
      @json ||= JSON[payload.json]
    end
  end
end
