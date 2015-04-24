require 'rails/engine'
require "active_support/concern"
require "active_model_serializers"
require "inheritable_accessors"
require "matterhorn/version"
require "matterhorn/serialization"
require "matterhorn/request_env"
require "matterhorn/link"
require "matterhorn/inclusion"
require "matterhorn/ordering"
require "matterhorn/paging"
require "inherited_resources/base_helpers"
require "inherited_resources/belongs_to_helpers"
require "inherited_resources/class_methods"
require "inherited_resources/url_helpers"
require "matterhorn/resource"
require "matterhorn/resources"

module Matterhorn

  class ResourceError < StandardError
    DEFAULT_ERROR_CODE = 500
    attr_reader :status
    attr_reader :exception

    def initialize(exception)
      @exception = exception
      @status    = get_status_from_exception(exception)
    end

    def name
      @exception.to_s
    end

    def to_response_options
      {
        json:   Serialization::ErrorSerializer.new(self).serializable_hash,
        status: status
      }
    end

  protected ####################################################################

    def get_status_from_exception(ex)
      case ex
        when ::ActionController::UnknownFormat then 406
        else
          DEFAULT_ERROR_CODE
      end
    end

  end
end

if defined?(Rails)
  module Matterhorn
    class Railtie < ::Rails::Engine
      initializer "serialization.matterhorn" do |app|
        Matterhorn::Serialization::UrlBuilder.send :include, Rails.application.routes.url_helpers
      end
    end
  end
end

ActiveModel::Serializer.send :prepend, Matterhorn::Serialization::BuilderSupport
ActiveModel::Serializer.send :include, Matterhorn::Serialization::SerializationSupport
