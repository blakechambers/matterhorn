require "matterhorn/paging/config"
require "matterhorn/paging/default"
require "matterhorn/paging/per_page"

module Matterhorn
  module Paging

    extend ActiveSupport::Concern

    module ClassMethods

      attr_accessor :pagination_config

      def paginates_with(pagination_class)
        pagination_class.interfaced(self)
        self.pagination_config.set_pagination_class(pagination_class)
      end
    end

    included do
      self.pagination_config = Matterhorn::Paging::Config.new

      def pagination_config
        self.class.pagination_config
      end
    end
  end
end
