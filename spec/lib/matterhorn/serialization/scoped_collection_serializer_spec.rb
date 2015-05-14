require 'spec_helper'

RSpec.describe "Matterhorn::Serialization::ScopedCollectionSerializer" do

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
    define_class(:Author) do
      include Mongoid::Document
      field :name
    end
  end

  let!(:serializer_class) do
    define_class(:ArticleSerializer, Matterhorn::Serialization::BaseSerializer) do
      attributes :id, :author_id
    end
  end

  let!(:author_serializer) do
    define_class(:AuthorSerializer, Matterhorn::Serialization::BaseSerializer) do
    end
  end

  let(:request_env) do
    Matterhorn::RequestEnv.new.tap do |env|
      env[:url_builder] = url_builder
    end
  end

  let(:serializer) { Matterhorn::Serialization::ScopedCollectionSerializer.new(Article.all, root: nil, request_env: request_env) }
  let(:body) { SerialSpec::ParsedBody.new(serializer.to_json) }

  subject { serializer }

  it "should have top level self link" do
    expect(body[:links][:self].execute).to eq("http://example.org/articles/{articles._id}")
  end

  it "should have author top level" do
    expect(body[:links][:author].execute).to eq(nil)
  end

  context "when no links are specified, and inclusion_support is not mixed" do

    let!(:article_class) do
      define_model(:Article) do
        belongs_to :author
      end
    end

    it "should not raise an error" do
      article = Article.create!

      expect{body[:links].execute}.to_not raise_error
    end

  end

  context "when including relations" do
    let(:request_env) do
      Matterhorn::RequestEnv.new.tap do |env|
        env[:url_builder] = url_builder
        env[:include_param] = "author"
      end
    end

    it "should include requested items" do
      author  = author_class.create!
      article = article_class.create! author: author

      included = body[:includes].first
      
      expect(included[:id].execute).to   eq(author.id.to_s)
      expect(included[:type].execute).to eq("authors")
    end

  end

  context "when including non-includable links" do
    let(:request_env) do
      Matterhorn::RequestEnv.new.tap do |env|
        env[:url_builder] = url_builder
        env[:collection_params] = { include: "self" }
      end
    end

    it "should include requested items" do
      author  = author_class.create!
      article = article_class.create! author: author

      included = body[:includes].execute
      expect(included).to be_empty
    end

  end

  context "when including invalid relations" do
    let(:request_env) do
      Matterhorn::RequestEnv.new.tap do |env|
        env[:url_builder] = url_builder
        env[:collection_params] = { include: "foo" }
      end
    end

    it "should include requested items" do
      expect{body.execute}.to_not raise_error
    end

  end

end
