require "matterhorn/serialization/scoped"

module Matterhorn
  module Serialization
    class ScopedCollectionSerializer < ScopedBase
      include Scoped
      include Serialization::Scoped::MergeLinks

      def order_config
        options[:order_config]
      end

      def pagination
        options[:pagination]
      end

      def order_object
        if order_config
          order_name =  (request_env[:collection_params][:order] || order_config.default_order)
          order_by   = order_config.order_for(order_name)
          @object = object.order_by(order_by)
        end
      end

      def page_object
        if pagination
          @object = pagination.page_object(object)
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
