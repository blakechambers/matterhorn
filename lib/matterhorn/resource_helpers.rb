module Matterhorn
  module ResourceHelpers
    extend ActiveSupport::Concern

    module ClassMethods

      def add_env(name)
        serialization_env_names << name.to_sym
      end

      def allow_collection_params(*params)
        allowed_collection_params.merge params.flatten
      end

      def allow_resource_params(*params)
        allowed_resource_params.merge params.flatten
      end

    end

    included do

      protected ######################################################################

      def collection_params
        params.permit(self.class.allowed_collection_params.to_a)
      end

      # Multi-id request helpers
      ##########################

      # Returns collection if multi-id or regular request
      def collection_or_multi_id_collection
        if multi_ids_request?
          selector = {multi_id_key => multi_ids}
          set_collection(resource_class.in(selector))
        else
          collection
        end
      end

      def is_singleton?
        resources_configuration[:self][:singleton]
      end

      # simply grabs multi ids from request
      def multi_ids
        params[multi_id_key].split(',')
      end

      #TODO  This method needs review
      # This infers the key using a little inherited resource reflection
      def multi_id_key
        key = :id
        if parent?
          key = resources_configuration[symbols_for_association_chain[-1]][:param]
        end
        key
      end

      # just determine if this request is multi-id
      def multi_ids_request?
        params[multi_id_key] && params[multi_id_key].include?(',')
      end

      ###########
      #END Multi-id helpers

      # Standard Inherited Resources method, default in actions
      # override in controller for maximum control
      def permitted_params
        if is_singleton?
          singleton_permitted_params
        else
          params.require(:data).permit(allowed_resource_params.to_a)
        end
      end

      def singleton_permitted_params
        parent_key = symbols_for_association_chain[-1]
        # singleton_params = [data: allowed_resource_params.to_a]
        # association_hash = {resources_configuration[parent_key][:param] => params[resources_configuration[parent_key][:param]]}
        params.require(:data).permit(allowed_resource_params.to_a)
      end

      def collection_scope
        collection || resource_scope
      end

      def resource_name(name=nil)
        name || self.class.controller_name.singularize
      end

      def resource_scope
        resource || resource_name.classify.safe_constantize
      end

      def resource_or_multi_id_collection
        if multi_ids_request?
          set_resource(resource_class.in(id: multi_ids))
        else
          resource
        end
      end

      def resource_url(res=resource)
        Matterhorn::Serialization::UrlBuilder.new(url_options: self.url_options).url_for(res)
      end

      # These set vars straight into Inherited Resource conventions
      def set_collection(coll)
        set_collection_ivar(coll)
      end

      def set_resource(res)
        set_resource_ivar(res)
      end

      def with_scope(scope)
        @scope = scope
        yield(scope)
        @scope = nil
      end
    end
  end
end
