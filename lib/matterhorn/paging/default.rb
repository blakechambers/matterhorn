module Matterhorn
  module Paging
    class Default

      # provides a LinkSet or config that can be merged into the request later.  
      # Links should be defined as a type inheriting from SetMember directly, not
      # from the association base class.
      attr_reader :links

      # resource    - scope (generally a Mongoid::Criteria)
      # page_params - param.permit(pagination_params)
      def initialize(resource, request_env, page_params, options)
        @links = LinkSet.new
      end

      def self.interfaced(controller)
        controller.pagination_config.set_pagination_class(self)
        controller.pagination_config.set_page_param(:offset)
        controller.pagination_config.set_per_page_param(:limit)
        controller.allow_collection_params :limit, :offset
      end

      # specify the different types of links, and the code for each
      # here lets assume that we are defining, next, prev, and first.
      #
      # NOTE: this method will need access to the self link to be able
      #       to build first most of the time (i.e. to remove the current paging
      #       params)
      def self.links_config
        # ...
      end

    end
  end
end
