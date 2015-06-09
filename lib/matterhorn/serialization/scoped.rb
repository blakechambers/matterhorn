require "matterhorn/serialization/scoped/merge_inclusions"
require "matterhorn/serialization/scoped/merge_links"

module Matterhorn
  module Serialization

    module Scoped
      extend  ActiveSupport::Concern
      include Serialization::Scoped::MergeInclusions
    end

    class ScopedBase

      extend Forwardable

      attr_reader :object, :options, :collection_name, :resource_name, :ids, :request_env

      def_delegator :@url_builder, :url_for

      def initialize(object, options={})
        @object, @options = object, options.dup

        name = object.kind_of?(Enumerable) ? @object.klass.name : object.class.name

        @resource_name   = name.underscore
        @collection_name = @resource_name.pluralize
        @request_env     = options[:request_env]
        @url_builder     = options[:url_builder] || request_env[:url_builder]
      end

      def serialized_object
        @serialized_object ||= _serialized_object
      end

      def set_ids(*items)
        @ids = items.flatten.map do |item|
          item[ID_FIELD] || item[ID_FIELD.to_s]
        end
      end

      def serializable_hash
        set_ids(serialized_object)

        Hash.new.tap do |hash|
          hash.merge!(TOP_LEVEL_KEY=> serialized_object)
        end
      end

      def as_json(options={})
        serializable_hash
      end

    end
  end
end
