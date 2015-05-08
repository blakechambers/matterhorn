module Matterhorn
  module Links
    module Relation
      class Base < Links::SetMember
        extend ActiveModel::Naming

        attr_reader :resource_field_key
        attr_reader :inverse_field_key

        def initialize(name,config,options={})
          super
          configure_for_relation!
        end

        def configure_for_relation!
          raise NotImplementedError
        end

        def scope_class(reference=nil)
          @scope_class ||= (metadata || context).klass
        end

        def url_options(resource)
          opts = super(resource)
          if config.nested
            if opts.last.kind_of?(Hash)
              opts = [*opts.take(opts.size - 1), name, opts[-1]]
            else
              opts = [*opts, name]
            end
          end
          opts
        end

        def resource_url_options(resource)
          config.nested ? nested_member(resource) : relation_member(resource)
        end

        def scope_url_options(resource)
          template_for(relation_scope(resource))
        end

        def relation_scope(resource)
          config.nested ? resource : scope_class(resource)
        end

        def nested_member(resource)
          resource
        end

        def relation_member(resource)
          if metadata.polymorphic?
            faux_resource_for(scope_class(resource), resource.send(resource_field_key))
          else
            faux_resource_for(scope_class(resource), resource.send(resource_field_key))
          end
        end

        def faux_resource_for(resource, param)
          Matterhorn::UrlHelper::FauxResource.for(resource, param)
        end

        def self.is_valid_config?(link_config)
          return false unless link_config.metadata
          link_config.metadata.relation == Mongoid::Relations::Referenced::In
        end

        def inverse_id
          mongo_id_or_value(inverse_field_key)
        end

        def mongo_id_or_value(value)
          if value.to_s == Serialization::MONGO_ID_FIELD.to_s
            "id"
          else
            value
          end
        end
        # linkage and relate as a hash
        # TODO: possibly raise an error when the relations resource_field_key is
        #       not provide in the serializer.
        def serialize_resource(resource)
          link_id, link_type = link_id_and_type(resource)

          linkage = if link_id
            {
              inverse_id => link_id,
              :type    => link_type
            }
          else
            nil
          end

          {
            linkage: linkage,
            related: url_for(resource)
          }
        end

        def link_id_and_type(resource)
          klass = metadata.polymorphic? ? scope_class(resource) : metadata.class_name
          id = resource.respond_to?(resource_field_key) ? resource.send(resource_field_key) : nil
          [id, klass.to_s.underscore.pluralize]
        end

        # just the url of the relationship
        def serialize_collection(collection)
          url_for(collection)
        end

        def find(resources_array)
          ids = get_items_ids(resources_array)
          find_with_ids(resources_array.first, ids)
        end

        def find_with_ids(resource, ids)
          scope(resource).in(inverse_field_key => ids)
        end

        def get_items_ids(resources_array)
          resources_array.map do |item|
            item.send(resource_field_key)
          end.flatten
        end

        def scope(resource)
          @scope ||= begin
           config.scope.call(scope_class(resource), self, request_env)
          end
        end

        def url_builder
          request_env[:url_builder]
        end

        def persisted?
          true
        end

        def to_model
          self
        end

        def to_param
          name
        end

        private 

        def self.name
          "Link"
        end

      end
    end
  end
end
