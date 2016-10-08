require_dependency "bucket/application_controller"

module Bucket
  class BlocksController < ApplicationController
    before_action :set_block, only: [:show, :edit, :update, :destroy]

    # GET /blocks
    def index
      @sort_field = params[:sort_field].presence
      @sort_order = params[:sort_order].presence || 'ASC'
      @page = params[:page].presence || 1
      @query = params[:query].presence
      @operation_type = params[:operation_type].presence
      
      @blocks = case @sort_field
      when 'transactions_count'
        sub_select = <<-DONE
          (
            SELECT COUNT(*) FROM bucket_transactions
            WHERE bucket_blocks.id = bucket_transactions.block_id
          ) AS bucket_blocks_transactions_count
        DONE
        Block.select(Arel.star, sub_select).
          order("bucket_blocks_transactions_count #{@sort_order}")
      else
        Block.ordered(sort_field: @sort_field, sort_order: @sort_order)
      end

      
      @blocks = @blocks.query(@query) if !!@query
      @blocks = @blocks.has_operation_type(@operation_type) if !!@operation_type
      @blocks = @blocks.paginate(page: @page, per_page: 25)
    end

    # GET /blocks/1
    def show
    end

    # DELETE /blocks/1
    def destroy
      @block.destroy
      redirect_to blocks_url, notice: 'Block was successfully destroyed.'
    end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_block
      @block = Block.find(params[:id])
    end
  end
end
