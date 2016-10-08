module Bucket
  module ApplicationHelper
    def sortable_header_link_to(name, field)
      options = params.merge(action: controller.action_name, sort_field: field, page: nil, query: params[:query], sort_order: params[:sort_order] == 'asc' ? 'desc' : 'asc')
      options.permit!
      link_to name, url_for(options)
    end

    def operation_types_for_select(default = nil)
      types = Bucket::Operation.all.select(:type).pluck(:type).uniq.sort
      types_map = [[nil, nil]]
      
      types_map += types.map do |type|
        [type.split('::').last.titleize, type]
      end
      
      options_for_select(types_map, default)
    end
  end
end
