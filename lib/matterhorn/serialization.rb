require "matterhorn/serialization/builder_support"
require "matterhorn/serialization/scoped"
require "matterhorn/serialization/scoped_collection_serializer"
require "matterhorn/serialization/scoped_resource_serializer"
require "matterhorn/serialization/error_serializer"
require "matterhorn/url_helper"
require "cgi"

module Matterhorn
  module Serialization

    MONGO_ID_FIELD = :_id
    ID_FIELD       = :id
    TOP_LEVEL_KEY  = :data

    class BaseSerializer < ActiveModel::Serializer

      attributes :id,
                 :links,
                 :type

    protected ##################################################################

      def id
        object._id.to_s
      end

      def type
        object.class.name.underscore.pluralize
      end

      def object_link_config
        object.respond_to?(:__link_configs) ? object.__link_configs : Hash.new
      end

      def include_self_link?
        true
      end

      def links
        link_set_options = { context: object, request_env: request_env }
        model_links = Links::LinkSet.new(object_link_config, link_set_options)

        if include_self_link?
          self_config= Links::LinkConfig.new(nil, :self, type: :self)
          self_links = Links::LinkSet.new({self: self_config}, link_set_options)
          model_links.merge!(self_links.config)
        end

        link_set_serializer = LinkSetSerializer.new(model_links, context: object)
        link_set_serializer.serializable_hash
      end

      def request_env
        @options[:request_env]
      end

      def attributes
        _fast_attributes
        rescue NameError
          method = "def _fast_attributes\n"
          method << "  h = {}\n"
          method << "  h['attributes'] = {}\n"
          _attributes.each do |name,key|
            if key.in? [:id, :type, :links, :relationships]
              method << "  h[:\"#{key}\"] = read_attribute_for_serialization(:\"#{name}\") if include?(:\"#{name}\")\n"
            else
              method << "  h['attributes'][:\"#{key}\"] = read_attribute_for_serialization(:\"#{name}\") if include?(:\"#{name}\")\n"
            end
          end
          method << "  h\nend"
          self.class.class_eval method
          _fast_attributes
      end
    end

    class LinkSetSerializer
      attr_reader :link_set, :options, :context

      # object - a LinkSet instance
      # context - the thing you are serializing
      def initialize(link_set, options={})
        @link_set, @options = link_set, options
        @context = options[:context]
      end

      def serializable_hash
        link_set.inject(Hash.new) do |sum, pair|
          name, set_member = *pair

          sum[name] = set_member.serialize(context)
          sum
        end
      end
    end

    class URITemplate < ::Matterhorn::UrlHelper::FauxResource

      def to_param
        "{#{param}}"
      end

      def self.for(obj, param)
        build_for(obj).new(obj, param)
      end

      def self.build_for(obj)
        Class.new(URITemplate).tap do |klass|
          klass.module_eval <<-METHOD
            def self.name
              "#{Matterhorn::Serialization.classify_name(obj).name}"
            end
          METHOD
        end
      end

    end

    def self.classify_name(obj)
      case obj
      when Mongoid::Criteria then obj.klass
      when Mongoid::Document then obj.class
      when Class             then obj
      else
        raise ArgumentError, "unable to classify: #{obj.inspect}"
      end
    end

    class UrlBuilder

      def initialize(options={})
        self.default_url_options = options[:url_options]
      end

      def url_for(*args)
        CGI.unescape(super(*args))
      end

      def ==(other)
        other.default_url_options == default_url_options
      end

    end

  end
end
