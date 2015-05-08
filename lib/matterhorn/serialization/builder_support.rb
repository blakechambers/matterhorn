module Matterhorn
  module Serialization
    module BuilderSupport

      module ActiveModelSerializersPatch
        # this is a very explicit override of what activemodel serializers chooses
        # to do to serialize models.  Matterhorn ignores the root and context
        # (i.e. `current_user`) among other things.
        #
        #
        def build_json(controller, resource, options)
          options[:url_options]           = controller.url_options
          serialization_env = controller.serialization_env_names.to_a.inject(Hash.new) do |sum, name|
            sum[name] = controller.send(name)
            sum
          end

          request_env = RequestEnv.new(serialization_env)

          # TODO remove options url_builder
          request_env[:url_builder] = options[:url_builder] = UrlBuilder.new url_options: options[:url_options]
          request_env[:collection_params] = controller.send(:collection_params)
          request_env[:include_param]     = controller.params.fetch(:include, "")

          if controller.respond_to? :pagination_config
            options[:pagination]  = controller.pagination_config.pagination_class.new(resource, request_env)
          end
          
          if controller.respond_to? :order_config
            options[:order_config]  = controller.send("order_config")
          end

          options[:request_env] = request_env
          return resource if resource.kind_of?(Hash)

          serializer = if resource.kind_of?(Matterhorn::Links::Relation::BelongsTo)
           LinkSerializer
          elsif resource.kind_of?(Matterhorn::Links::Relation::HasOne)
            LinkSerializer
          elsif resource.kind_of?(Matterhorn::Links::Relation::HasMany)
            LinkSerializer
          elsif resource.kind_of?(Enumerable)
            ScopedCollectionSerializer
          else
            ScopedResourceSerializer
          end

          ser = serializer.new(resource, options)
        end

      end

      def self.prepended(base)
        class << base
          prepend ActiveModelSerializersPatch
        end
      end


    end
  end
end
