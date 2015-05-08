module UrlTestHelpers
  extend ActiveSupport::Concern
  include InheritableAccessors::InheritableHashAccessor

  included do
    include ::UrlTestHelpers::DSL
    extend  ::UrlTestHelpers::DSL

    inheritable_hash_accessor :__url_test_helpers__

    let(:routes_set) { ActionDispatch::Routing::RouteSet.new }

    let(:routes) do
      routes_set.draw &routes_config
      routes_set
    end

    let(:url_builder_class) do
      klass = define_class(:UrlConstructor, ::Matterhorn::Serialization::UrlBuilder)
      klass.send :include, routes.url_helpers
      klass
    end

    let(:url_options) do
      {host: "example.org" , }
    end

    let(:url_builder) do
      url_builder_class.new url_options: url_options
    end

  end

  def url_for(*args)
    url_builder.url_for(*args)
  end

  module DSL
    def routes_config(&block)
      __url_test_helpers__[:routes_config] = block if block_given?
      __url_test_helpers__[:routes_config]
    end
  end


end
