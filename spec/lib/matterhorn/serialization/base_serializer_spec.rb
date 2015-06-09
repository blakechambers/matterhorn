require 'spec_helper'

RSpec.describe "Matterhorn::Serialization::BaseSerializer" do

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
  let(:serialized_article) { ArticleSerializer.new(article, root: nil, request_env: request_env).as_json }
  let(:body) { SerialSpec::ParsedBody.new(serialized_article.to_json) }

  subject { serialized_article }

  it "[REMOVE] should serialize without any errors" do
    expect(serialized_article).to be_a_kind_of(Hash)
  end

  it "should wrap attributes inside an attributes hash" do
    expect(serialized_article["attributes"]).to eq({:_id => article.id, :author_id => author.id })
  end

  it "should include links[self] reference" do
    expect(body[:links].execute).to be_kind_of(Hash)
    expect(body[:links][:self].execute).to eq(url_builder.article_url(article))
  end

  it "should serialize links specified in model" do
    relation = body[:relationships][:author]

    expect(relation[:related].execute).to        eq(url_builder.author_url(author))
    expect(relation[:linkage][:id].execute).to   eq(author._id.to_s)
    expect(relation[:linkage][:type].execute).to eq("authors")
  end

  # TODO:
  # context "when no routes provided" do
  #   it "should raise 'no routes defined for object'"
  # end

  context "when no links are specified" do

    let!(:article_class) do
      define_class(:Article,base_class) do
        belongs_to :author
      end
    end

    it "should not raise an error" do
      expect(body[:links].execute).to be_kind_of(Hash)
      expect(body[:links][:self].execute).to eq(url_builder.article_url(article))
    end

  end

end
