module Matterhorn
  module UrlHelper
    class FauxResource
      extend ActiveModel::Naming

      class_attribute :_templates
      self._templates = {}

      attr_reader :param

      def initialize(obj, param)
        @obj   = obj
        @param = param
      end

      def to_param
        "#{param}"
      end

      def persisted?
        true
      end

      def to_model
        self
      end

      def self.for(obj, param)
        build_for(obj).new(obj, param)
      end

      def self.build_for(obj)
        Class.new(FauxResource).tap do |klass|
          klass.module_eval <<-METHOD
            def self.name
              "#{Matterhorn::Serialization.classify_name(obj).name}"
            end
          METHOD
        end
      end

    end

    # generates a collection url from resource or criteria
    class CollectionURI
      extend ActiveModel::Naming

      def initialize(obj, field="_id")
        @obj   = obj
        @field = field
      end

      def self.for(obj)
        build_for(obj).new(obj)
      end

      def to_param
        @obj.kind_of?(Mongoid::Criteria) ? collection_to_param : @obj.to_param
      end

      def collection_to_param
        raise ArgumentError, "must be a collection" unless @obj.kind_of?(Mongoid::Criteria)

        @obj.pluck(:_id).join(",")
      end

      def persisted?
        false
      end

      def to_model
        self
      end

      def self.build_for(obj)
        Class.new(CollectionURI).tap do |klass|
          klass.module_eval <<-METHOD
            def self.name
              "#{Matterhorn::Serialization.classify_name(obj).name}"
            end
          METHOD
        end
      end

    end

  end
end
