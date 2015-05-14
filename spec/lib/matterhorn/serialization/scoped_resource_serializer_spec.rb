require 'spec_helper'

RSpec.describe "Matterhorn::Serialization::ScopedResourceSerializer" do

  include ClassBuilder
  include UrlTestHelpers

  routes_config do
    resources :articles
    resources :authors
  end

  let!(:article_class) do
    define_model(:Article) do
      belongs_to :author
      add_link   :author
    end
  end

  let!(:author_class) do
    define_model(:Author) do
      field :name
    end
  end

  let!(:serializer_class) do
    define_class(:ArticleSerializer, Matterhorn::Serialization::BaseSerializer) do
      attributes :_id, :author_id
    end
  end

  let(:request_env) do
    Matterhorn::RequestEnv.new.tap do |env|
      env[:url_builder] = url_builder
    end
  end

  let(:author)  { Author.create }
  let(:article) { article_class.create author: author}
  let(:serializer) { Matterhorn::Serialization::ScopedResourceSerializer.new(article, root: nil, request_env: request_env) }
  let(:body) { SerialSpec::ParsedBody.new(serializer.to_json) }

  subject { serializer }

  it "should have top level type" do
    expect(body[:data][:type].execute).to eq("articles")
  end

  it "should have top level self link" do
    expect(body[:links][:self].execute).to eq("http://example.org/articles/{articles._id}")
  end

  it "should have author top level" do
    expect(body[:links][:author].execute).to eq(nil)
  end

end
