module Matterhorn
  module Links
    class SetMember
      attr_reader :config

      # Context is the current object being serialized.
      # This will generally be a Criteria, Model or a small array of context
      # objects (i.e. in the case of nested routes /posts/1,2,3/vote, the 3
      # posts would be an array).
      attr_reader :context
      attr_reader :options
      attr_reader :foreign_key
      attr_reader :inclusion_lookup_key
      attr_reader :metadata
      attr_reader :name
      attr_reader :relation_name
      attr_reader :request_env
      attr_reader :serializer
      attr_reader :template_key

      def initialize(name, config, options={})
        @name             = name
        @config           = config
        @scope_class      = config.scope_class
        @options          = options
        @context          = options[:context]
        @request_env      = options[:request_env]
        @relation_name    = config.relation_name
        @metadata         = config.metadata
        @inclusion        = false
      end

      def set_inclusion
        @inclusion = true
      end

      def url_builder
        request_env[:url_builder]
      end

      def template_for(resource)
        Serialization::URITemplate.for(resource, @template_key.call(resource))
      end

      def with_matterhorn_resource_opts(resource, opts)
        resource_class = Serialization.classify_name(resource)
        resource_class.respond_to?(:matterhorn_url_options) ? resource_class.matterhorn_url_options(opts) : [opts]
      end

      def url_options(resource)
        opts = case resource
        when Mongoid::Document then resource_url_options(resource)
        when Mongoid::Criteria then scope_url_options(resource)
        else
          raise "Could not decide how to build association from #{resource.inspect}"
        end

        opts = with_matterhorn_resource_opts(resource, opts)

        if !@inclusion and request_env[:collection_params]
          if opts.last.kind_of?(Hash)
            opts.last.merge(request_env[:collection_params])
          else
            opts.append(request_env[:collection_params].clone)
          end
        end

        opts
      end

      def url_for(resource)
        url_builder.url_for(url_options(resource))
      end

      def resource_url_options(resource)
        resource
      end

      def scope_url_options(resource)
        template_for(relation_scope(resource))
      end

      def relation_scope(resource)
        scope_class(resource)
      end

      def nested_member(resource)
        resource
      end

      def serialize(resource)
        case resource
        when Mongoid::Document         then serialize_resource(resource)
        when Mongoid::Criteria         then serialize_collection(resource)
        when Mongoid::Relations::Proxy then serialize(resource.target)
        else
          raise ArgumentError, "Could not decide how to build association from #{resource.inspect}"
        end
      end

      def serialize_resource(resource)
        url_for(resource)
      end

      def resource_class(resource)
        result = case resource
        when Mongoid::Document         then resource.class
        when Mongoid::Criteria         then resource.klass
        when Mongoid::Relations::Proxy then resource_class(resource.target)
        when Class                     then resource
        else
          raise ArgumentError, "could not determine a class for '#{resource.inspect}'"
        end
      end

      def resource_name(resource)
        resource_class(resource).name.to_s.underscore.pluralize
      end

      def serialize_collection(collection)
        url_for(collection)
      end

      def self.is_valid_config?(link_config)
        raise 'must be reimplemented'
      end

    end
  end
end
