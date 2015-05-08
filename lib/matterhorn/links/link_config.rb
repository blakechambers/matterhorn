module Matterhorn
  module Links

    # the class originating the scope.  Initially matterhorn will provide 2
    # different locations for the scope to be defined: Controller and a
    # model.
    #
    # During serialization, an instance of the base_class should be provided
    # as context. This allows associations defined in the controller to have
    # accessibilty to helper_methods (e.g. `current_user`), or in model (not
    # really a great case for it here except to provide common inclusions any
    # place that the model is used in the api).
    #
    # Usage:
    #
    #     class Post
    #       include Mongoid::Docuument
    #       include Matterhorn::Links::LinksSupport
    #
    #       belongs_to :author
    #       add_link :author
    #     end
    #
    class LinkConfig

      DEFAULT_SCOPE = proc do |scope, set_member, request_env|
        scope
      end

      # Old attribute set, to cleanout
      attr_reader :as
      attr_reader :options
      attr_reader :metadata
      attr_reader :scope_class
      attr_reader :resource_field_key
      attr_reader :url_type

      # new attribute set
      attr_reader   :base
      attr_reader   :name
      attr_reader   :nested
      attr_reader   :relation_name
      attr_reader   :scope
      attr_reader   :serializer
      attr_reader   :singleton
      attr_accessor :type

      def initialize(base, name, options={})
        @base          = base
        @name          = name
        @options       = options.dup

        @relation_name = options.delete(:relation_name) || @name
        @nested        = options.delete(:nested)
        @serializer    = options.delete(:serializer)
        @singleton     = options.delete(:singleton)
        @scope         = options.delete(:scope) || DEFAULT_SCOPE
        @type          = options.delete(:type)

        construct_metadata! if @base

        @resource_field_key = options[:resource_field]
        @scope_class        = options[:scope_class]
      end

      def construct_metadata!
        @base = if @base.ancestors.include?(Matterhorn::Base)
          context.send(:read_resource_scope).klass
        elsif @base.ancestors.include?(Mongoid::Document)
          @base
        else

          raise StandardError, "could not construct metadata from '#{config.inspect}'"
        end

        @metadata = @base.reflect_on_association(relation_name)
      end

      def base_class
        base
      end

    end
  end
end
