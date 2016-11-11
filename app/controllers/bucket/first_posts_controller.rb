require_dependency "bucket/application_controller"

module Bucket
  class FirstPostsController < ApplicationController
    # GET /first_posts
    def index
      @sort_field = params[:sort_field].presence
      @sort_order = params[:sort_order].presence || 'ASC'
      @page = params[:page].presence || 1
      @query = params[:query].presence
      
      @first_posts = Operation::Comment.where('created_at > ?', 24.hours.ago).root_posts
      @first_posts = @first_posts.ordered(sort_field: @sort_field, sort_order: @sort_order)
      @first_posts = @first_posts.first_posts
      
      @first_posts = @first_posts.query(@query) if !!@query
      @first_posts = @first_posts.paginate(page: @page, per_page: 25)
    end
  end
end
