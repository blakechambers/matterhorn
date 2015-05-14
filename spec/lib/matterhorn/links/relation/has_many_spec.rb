require "spec_helper"
require "class_builder"
require "action_dispatch/routing"

RSpec.describe "Matterhorn::Links::Relation::HasOne" do
  include ClassBuilder
  include UrlTestHelpers
  include SerialSpec::ItExpects

  routes_config do
    resources :articles
    resources :mentions
  end

  let!(:article_class) do
    define_model(:Article) do
      has_many   :mentions
      add_link   :mentions,
        nested: true
    end
  end

  let!(:mention_class) do
    define_model(:Mention) do
      include Mongoid::Document

      belongs_to :article
      field :name
    end
  end

  let!(:comment)    { mention_class.create article: article }
  let(:article)    { article_class.create }
  let(:set_member) { link_set[:mentions] }
  let(:link_set)   { Matterhorn::Links::LinkSet.new(article_class.__link_configs, context: article_class, request_env: request_env)}

  it "should set relation to type Links::HasMany" do
    expect(set_member).to be_kind_of(Matterhorn::Links::Relation::HasMany)
  end

  let(:request_env) do
    Matterhorn::RequestEnv.new.tap do |env|
      env[:url_builder] = url_builder
    end
  end

  let(:url) { set_member.url_for(link_context) }
  let(:serialized) { set_member.serialize(link_context) }
  let(:parsed_serialized) { SerialSpec::ParsedBody.new(serialized.to_json) }

  context "when not nested" do

    let!(:article_class) do
      define_model(:Article) do
        has_many   :mentions
        add_link   :mentions,
          nested: false
      end
    end

    it 'should raise an error' do
      expect{set_member}.to raise_error(Matterhorn::Links::ConfigurationError)
    end

  end

  # context "when relation is polymorphic" do
  #   let!(:article_class) do
  #     define_class(:Article, base_class) do
  #       has_one    :author
  #       add_link   :author
  #     end
  #   end
  #
  #   let!(:bot_class) do
  #     define_class(:Bot, base_class) do
  #       include Mongoid::Document
  #
  #       field :name
  #     end
  #   end
  #
  #   routes_config do
  #     resources :articles
  #     resources :bots
  #     resources :authors
  #   end
  #
  #   let(:bot)     { bot_class.create }
  #   let(:author)  { bot }
  #   let(:article) { article_class.create author: bot}
  #
  #   context "when context: model" do
  #     let(:link_context) { article }
  #
  #     it { expect(url).to eq("http://example.org/bots/#{author._id}") }
  #     it { expect(parsed_serialized[:related].execute).to eq("http://example.org/bots/#{author._id}") }
  #     it { expect(parsed_serialized[:linkage][:id].execute).to   eq(author._id.to_s) }
  #     it { expect(parsed_serialized[:linkage][:type].execute).to eq("bots") }
  #   end
  # end

  context "when nested" do

    routes_config do
      resources :articles do
        resource :mentions
      end
    end

    let!(:article_class) do
      define_model(:Article) do
        has_many   :mentions
        add_link   :mentions,
          nested: true
      end
    end

    context "when context: criteria" do
      let(:link_context) { article_class.all }

      it { expect(url).to eq("http://example.org/articles/#{article._id}/mentions") }
    end

    context "when context: model" do
      let(:link_context) { article }

      it { expect(url).to eq("http://example.org/articles/#{article._id}/mentions") }
      it { expect(parsed_serialized[:linkage][:article_id].execute).to   eq(article._id.to_s) }
      it { expect(parsed_serialized[:linkage][:type].execute).to eq("mentions") }
    end

  end

  context "top level objects are using namespaces" do

    routes_config do
      namespace :foo do
        resources :articles do
          resource :mentions
        end
      end
    end

    let!(:article_class) do
      define_model(:Article) do
        has_many   :mentions
        add_link   :mentions,
          nested: true

        def self.matterhorn_url_options(obj)
          [:foo, obj]
        end
      end
    end

    let(:link_context) { article }

    it { expect(url).to eq("http://example.org/foo/articles/#{article._id}/mentions") }
    it { expect(parsed_serialized[:linkage][:article_id].execute).to eq(article._id.to_s) }
    it { expect(parsed_serialized[:linkage][:type].execute).to eq("mentions") }
  end

  context "#find" do
    let(:link_context) { article }
    let(:resource_array){ [article] }

    it "should return a enumerator of items matching the scope" do
      result = set_member.find(resource_array)

      expect(result).to be_kind_of(Mongoid::Criteria)
      expect(result).to include(comment)
    end

  end

end
