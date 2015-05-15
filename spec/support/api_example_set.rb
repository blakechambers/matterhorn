module ApiExampleSet
  extend ActiveSupport::Concern
  include SerialSpec
  include ResourceHelpers
  include ClassBuilder

  included do
    let(:url_builder_class) do
      klass = define_class(:UrlConstructor, ::Matterhorn::Serialization::UrlBuilder)
      klass.send :include, Rails.application.routes.url_helpers
      klass
    end

    let(:url_builder) do
      url_builder_class.new url_options: { host: "example.org" }
    end

    let(:request_env) do
      Matterhorn::RequestEnv.new.tap do |env|
        env[:url_builder] = url_builder
      end
    end
  end

  def build_serializer(serializer, obj, options)
    serializer.new(obj, options.merge!(request_env: request_env))
  end

  def provide_linked(obj)
    provide(obj, as: Matterhorn::Serialization::LinkResourceSerializer)
  end

  def app
    Rails.application
  end

end
