module Bucket
  class Operation::Comment < Bucket::Operation
    scope :author, lambda { |author, options = {}|
      comment = Comment.arel_table
      query_string = "%\"author\":\"#{author}\"%"
      
      where(comment[:payload].matches(query_string)).tap do |r|
        return !!options[:invert] ? where.not(id: r.select(:id)) : r
      end
    }
    
    scope :root_posts, -> { query('"parent_author":""') }
    scope :first_posts, -> {
      posts = all.root_posts
      authors = posts.map(&:author)
      api = Radiator::Api.new
      accounts = api.lookup_account_names(authors).result
      accounts = accounts.select do |account|
        account.post_count < 10
      end
      authors = accounts.map(&:name)
      
      posts = posts.select do |post|
        authors.include? post.author
      end
      
      all.where(id: posts.map(&:id))
    }
  end
end
