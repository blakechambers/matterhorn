require "matterhorn/serialization/scoped/link_support"

module Matterhorn
  module Serialization
    module Scoped
      module MergeInclusions
        extend ActiveSupport::Concern
        include LinkSupport

        def serializable_hash
          merge_inclusions! super()
        end

      protected ################################################################

        def merge_inclusions!(hash)
          include_param = request_env[:include_param] || ""
          requested_includes = include_param.split(",")

          results = []

          items = [serialized_object].flatten
          resources_array = [object].flatten

          items_sets = resources_array.inject(Hash.new) do |klasses, x|
            klasses[x.class] ||= []
            klasses[x.class] << x
            klasses
          end

          items_sets.each do |klass, items|
            next unless items.first.respond_to?(:links)

            items.first.links(request_env: request_env).each do |pair|
              name, member = *pair

              if member.respond_to?(:includable?) and
                 member.includable? and
                 requested_includes.include?(name.to_s)

                results.concat member.find(items).to_a
              end
            end
          end

          items = results.map do |result|
            if result.respond_to?(:active_model_serializer)
              result.active_model_serializer.new(result, options.merge(root: nil, inclusion: true, request_env: request_env)).serializable_hash
            else
              result.as_json(options.merge(root: nil))
            end
          end

          hash["includes"] = items
          hash
        end

      end
    end
  end
end
