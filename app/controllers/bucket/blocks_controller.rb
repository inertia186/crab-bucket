require_dependency "bucket/application_controller"

module Bucket
  class BlocksController < ApplicationController
    before_action :set_block, only: [:show, :edit, :update, :destroy]

    # GET /blocks
    def index
      @page = params[:page] || 1
      @blocks = Block.all
      
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
