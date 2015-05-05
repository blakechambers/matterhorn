module Matterhorn
  module Serialization
    module Scoped
      module LinkSupport

      protected ################################################################

        def object_link_config
          object.respond_to?(:__link_configs) ? object.__link_configs : Hash.new
        end

        def links
          @links ||= begin
            link_set_options = { context: object, request_env: request_env }
            model_links = Links::LinkSet.new(object_link_config, link_set_options)
            self_config = Links::LinkConfig.new(nil, :self, type: :self)
            self_links  = Links::LinkSet.new({self: self_config}, link_set_options)

            model_links.merge!(self_links.config)

            if options[:pagination]
              model_links.merge!(options[:pagination].links(link_set_options).config)
            end 

            model_links
          end
        end
      end
    end
  end
end
