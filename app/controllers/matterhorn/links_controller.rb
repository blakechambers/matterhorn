module Matterhorn
  class LinksController < Base
    include Matterhorn::Resource
    resource!
    protected ########

    def parent_class

      name, id = params.to_a[2..-3].last
      class_name = name.sub(/_id$/, "").camelize

      class_name.safe_constantize
    end

    def parent
      name, id = params.to_a[2..-3].last

      @parent ||= parent_class.find(id)
    end

    def link_name
      params[:id].to_sym
    end

    def resource
      parent.links[link_name]
    end

  end
end
