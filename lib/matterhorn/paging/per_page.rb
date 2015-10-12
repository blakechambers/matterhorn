module Matterhorn
  module Paging
    class PerPage

      # provides a LinkSet or config that can be merged into the request later.  
      # Links should be defined as a type inheriting from SetMember directly, not
      # from the association base class.
      attr_reader :links, :request_env

      # resource    - scope (generally a Mongoid::Criteria)
      # page_params - param.permit(pagination_params)
      def initialize(resource, request_env)
        @object = resource
        @request_env = request_env
      end

      def page_object(object)
        object = object.page(page).per(per_page)
      end

      def per_page
        if collection_params[:per_page]
          collection_params[:per_page].to_i
        else
          20
        end
      end

      def page
        if collection_params[:page]
          collection_params[:page].to_i
        else
          1
        end
      end

      def collection_params
        request_env[:collection_params]
      end

      def self.interfaced(controller)
        controller.pagination_config.set_pagination_class(self)
        controller.allow_collection_params :page, :per_page
      end

      def total_objects
        @object.total_count
      end

      def next_page_params
        {
          page: page + 1,
          per_page: per_page
        }
      end

      def prev_page_params
        params = { }
        params[:page] = page - 1  if page > 1
        params[:per_page] = per_page
        params
      end

      def first_page_params
        { per_page: per_page }
      end

      def link_configs
        {
          next: next_link_config,
          prev: prev_link_config,
          first: first_link_config
        }
      end

      def next_link_config
        Links::LinkConfig.new(nil, :paging, type: :paging, page_params: next_page_params)
      end

      def prev_link_config
        Links::LinkConfig.new(nil, :paging, type: :paging, page_params: prev_page_params)
      end

      def first_link_config
        Links::LinkConfig.new(nil, :paging, type: :paging, page_params: first_page_params)
      end

      def links(link_set_options)
        Links::LinkSet.new(link_configs, link_set_options)
      end

      def ==(other)
        self.class == other.class
      end

    end
  end
end
