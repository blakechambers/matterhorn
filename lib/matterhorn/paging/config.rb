module Matterhorn
  module Paging
    class Config

      attr_accessor :page_param, :pagination_class, :per_page_param

      def initialize(options={})
        @pagination_class = options.fetch(:pagination_class, Matterhorn::Paging::Default)
        @per_page_param = options.fetch(:per_page_param, 25)
      end

      def ==(other)
        pagination_class == other.pagination_class
      end

      def set_page_param(name)
        @page_param = name
      end

      def set_per_page_param(name)
        @per_page_param = name
      end

      def set_pagination_class(pagination_class)
        @pagination_class = pagination_class
      end
    end
  end
end
