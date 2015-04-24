require "matterhorn/serialization/scoped"

module Matterhorn
  module Serialization
    class ScopedCollectionSerializer
      include Scoped

      def serializable_hash
        super.merge!(TOP_LEVEL_KEY => serialized_object)
      end

      def order_config
        request_env[:order_config]
      end

      def pagination_config
        request_env[:pagination_config]
      end

      def order_object
        if order_config
          order_name =  (options[:collection_params][:order] || order_config.default_order)
          order_by   = order_config.order_for(order_name)
          @object = object.order_by(order_by)
        end
      end

      def page_object
        if pagination_config
          page = options[:collection_params][pagination_config.page_param]
          per_page = options[:collection_params][pagination_config.per_page_param]
          if per_page
            @object = object.limit(per_page)
          end
          if page
            @object = object.offset(page)
          end
        end
      end
         
      def _serialized_object
        order_object
        page_object
        collection_serializer = ActiveModel::ArraySerializer.new(object.to_a, options)
        collection_serializer.serializable_array
      end

    end
  end
end
