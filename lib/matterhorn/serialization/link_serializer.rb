require "matterhorn/serialization/scoped"

module Matterhorn
  module Serialization
    class LinkSerializer

      extend Forwardable

      attr_reader :object, :options, :request_env, :context

      def_delegator :url_builder, :url_for

      def initialize(object, options={})
        @object, @options = object, options.dup

        name = object.kind_of?(Enumerable) ? @object.klass.name : object.class.name

        @request_env       = options[:request_env]
        object.request_env = options[:request_env]

      end

      def serializable_hash 
        top_level_links.merge!(data_links)
      end

      def top_level_links
        {
          links: {
            related: url_for([object.context,object.name]),
            self: url_for([object.context,object])
          }
        }
      end

      def data_links

        resources_array = [object.context].flatten

        scope = 
          case object.config.type
          when :belongs_to
            object.find(resources_array).first
          when :has_many    
            object.find(resources_array)
          when :has_one
            object.find(resources_array).first
          end

        data = if scope.kind_of?(Enumerable)
          ActiveModel::ArraySerializer.new(scope, each_serializer: LinkResourceSerializer).as_json
        else
          LinkResourceSerializer.new(scope).serializable_hash
        end
        {Matterhorn::Serialization::TOP_LEVEL_KEY => data}
      end

      def as_json(options={})
        serializable_hash
      end

      def url_builder
        request_env[:url_builder]
      end

      class LinkResourceSerializer < ActiveModel::Serializer
        attributes :id, :type
        def include__id?
          false
        end
        def id
          object._id.to_s
        end
        def type
          object.class.to_s.underscore.pluralize
        end
      end
    end
  end
end
