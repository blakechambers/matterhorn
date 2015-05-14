require "spec_helper"
require "class_builder"
require "action_dispatch/routing"

RSpec.describe "Matterhorn::Links::Relation::BelongsTo" do
  include ClassBuilder
  include UrlTestHelpers
  include SerialSpec::ItExpects

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

  let(:author)     { author_class.create }
  let(:article)    { article_class.create author: author}
  let(:set_member) { link_set[:author] }
  let(:link_set)   { Matterhorn::Links::LinkSet.new(article_class.__link_configs, context: article_class, request_env: request_env)}
  let(:resource_array){ [article] }

  let(:request_env) do
    Matterhorn::RequestEnv.new.tap do |env|
      env[:url_builder] = url_builder
    end
  end

  let(:link_context) { article }

  let(:url) { set_member.url_for(link_context) }
  let(:serialized) { set_member.serialize(link_context) }
  let(:parsed_serialized) { SerialSpec::ParsedBody.new(serialized.to_json) }

  it "should set relation to type Links::BelongsTo" do
    expect(set_member).to be_kind_of(Matterhorn::Links::Relation::BelongsTo)
  end

  context "when not nested" do

    context "when context: criteria" do
      let(:link_context) { Article.all }

      it { expect(url).to eq("http://example.org/authors") }
      it { expect(serialized).to eq("http://example.org/authors") }
    end

    context "when context: model" do

      it { expect(url).to eq("http://example.org/authors/#{author._id}") }
      it { expect(parsed_serialized[:related].execute).to eq("http://example.org/authors/#{author._id}") }
      it { expect(parsed_serialized[:linkage][:id].execute).to   eq(author._id.to_s) }
      it { expect(parsed_serialized[:linkage][:type].execute).to eq("authors") }
    end

  end

  context "when relation is polymorphic" do
    let!(:article_class) do
      define_model(:Article) do
        belongs_to :author, polymorphic: true
        add_link   :author
      end
    end

    let!(:bot_class) do
      define_model(:Bot) do
        field :name
      end
    end

    routes_config do
      resources :articles
      resources :bots
      resources :authors
    end

    let(:bot)     { bot_class.create }
    let(:author)  { bot }
    let(:article) { article_class.create author: bot}

    context "when context: model" do
      it { expect(url).to eq("http://example.org/bots/#{author._id}") }
      it { expect(parsed_serialized[:related].execute).to eq("http://example.org/bots/#{author._id}") }
      it { expect(parsed_serialized[:linkage][:id].execute).to   eq(author._id.to_s) }
      it { expect(parsed_serialized[:linkage][:type].execute).to eq("bots") }
    end
  end

  context "when nested" do

    let!(:article_class) do
      define_model(:Article) do
        belongs_to :author
        add_link   :author,
          nested: true
      end
    end

    routes_config do
      resources :articles do
        resource :author
      end
    end

    context "when context: criteria" do
      let(:link_context) { article ; article_class.all }

      it { expect(url).to eq("http://example.org/articles/#{article._id}/author") }
    end

    context "when context: model" do
      it { expect(url).to eq("http://example.org/articles/#{article._id}/author") }
    end

  end

  context "top level objects are using namespaces" do

    routes_config do
      namespace :foo do
        resources :articles do
          resource :author
        end
      end
    end

    let!(:article_class) do
      define_model(:Article) do
        belongs_to :author
        add_link   :author,
          nested: true

        def self.matterhorn_url_options(obj)
          [:foo, obj]
        end
      end
    end

    it { expect(url).to eq("http://example.org/foo/articles/#{article._id}/author") }
  end

  context "#serialize" do
    let(:serialized) { set_member.serialize(link_context) }

    context 'when criteria' do
      let(:link_context) { article_class.all }
      it { expect(serialized).to eq("http://example.org/authors") }
    end

    context 'when resource is invalid' do
      let(:link_context) { nil }

      it { expect{serialized}.to raise_error(ArgumentError) }
    end

  end

  it "should be includable" do
    expect(set_member).to be_includable
  end

  context "#find" do
    it "should return a enumerator of items matching the scope" do
      result = set_member.find(resource_array)

      expect(result).to be_kind_of(Mongoid::Criteria)
      expect(result).to include(author)
    end

    it "should return an enumerator of items matching the scope if the field is not serialized" do
      result = set_member.find(resource_array)

      expect(result).to be_kind_of(Mongoid::Criteria)
      expect(result).to include(author)
    end

    context "with custom scope" do

      let(:scope_double) { double("scope") }

      let(:scope) do
        proc do |scope, set_member, request_env|
          scope_double
        end
      end

      let!(:article_class) do
        klass = define_class(:Article, base_class) do

          belongs_to :author
        end

        klass.send :add_link, :author, scope: scope
        klass
      end

      it "should call scope and return a enumerator of items matching the scope" do
        expect(scope_double).to receive(:in).once.and_return([author])
        result = set_member.find(resource_array)

        expect(result).to include(author)
      end

    end
  end

end
