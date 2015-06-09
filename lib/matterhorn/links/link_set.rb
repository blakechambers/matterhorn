require "matterhorn/serialization"

module Matterhorn
  module Links
    class LinkSet
      include ActiveModel::SerializerSupport

      extend  Forwardable

      def_delegators :config, :[], :[]=, :each, :inspect, :to_h, :merge!, :select!, :empty?, :inject
      attr_reader   :options
      attr_reader   :config

      def initialize(config, opts={})
        @options = opts.dup

        @config = config.to_hash.inject(Hash.new) do |members, pair|
          name, link_config = *pair
          name = name.to_sym

          link_class = Links.link_class_for_type(link_config.type)
          members[name] = link_class.new(name, link_config, options)
          members
        end
      end

      def ==(other)
        config == other.config
      end

      # def build_linkage(url_builder, serializer)
      #   inject(Hash.new) do |sum, pair|
      #
      #     name, link = *pair
      #     link.with_serializer(serializer) do
      #       if link.render?
      #         sum.merge!(link.name => link.linkage(url_builder))
      #       end
      #     end
      #     i
      #   end
      # end

      protected

      def set_config(hsh)
        @config = hsh
      end

    end
  end
end
