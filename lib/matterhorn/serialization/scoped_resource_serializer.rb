require "matterhorn/serialization/scoped"

module Matterhorn
  module Serialization
    class ScopedResourceSerializer
      include Scoped

      def initialize(object, options={})
        super(object, options)

        @serializer = options.delete(:serializer) ||
          (object.respond_to?(:active_model_serializer) &&
           object.active_model_serializer)
      end

      def serializable_hash
        super().merge!(resource_name => serialized_object)
      end

      def _serialized_object
        @serializer.new(object, options).serializable_hash
      end

    end
  end
end