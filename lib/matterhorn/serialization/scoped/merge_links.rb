require "matterhorn/serialization/scoped/link_support"

module Matterhorn
  module Serialization
    module Scoped
      module MergeLinks
        extend ActiveSupport::Concern
        include LinkSupport

        def serializable_hash
          merge_links! super()
        end

      protected ################################################################

        def merge_links!(hash)
          link_set_serializer = LinkSetSerializer.new(links, context: object)

          hash["links"] = link_set_serializer.serializable_hash

          if respond_to?(:order_config) and order_config
            link_set_options = { context: object, 
                                 collection_params: request_env[:collection_params], 
                                 request_env: request_env}
            link_set_serializer = LinkSetSerializer.new(options[:order_config].links(link_set_options), context: criteria)
            hash["orders"] = link_set_serializer.serializable_hash
          end

          hash
        end

      end
    end
  end
end
