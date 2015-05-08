require "spec_helper"
require "class_builder"
require "action_dispatch/routing"

RSpec.describe "Matterhorn::Links::SetMember" do
  include ClassBuilder
  include UrlTestHelpers
  include SerialSpec::ItExpects

  routes_config do
    resources :articles
    resources :authors
  end

  let(:base_class) do
    define_class(:BaseKlass) do
      include Mongoid::Document
      include Matterhorn::Links::LinkSupport
    end
  end

  let!(:article_class) do
    define_class(:Article, base_class) do
      belongs_to :author
      add_link   :author
    end
  end

  let!(:author_class) do
    define_class(:Author, base_class) do
      include Mongoid::Document

      field :name
    end
  end


  let(:author)     { author_class.create }
  let(:article)    { article_class.create author: author}
  let(:set_member) { link_set[:author] }
  let(:link_set)   { Matterhorn::Links::LinkSet.new(article_class.__link_configs, context: article_class, request_env: request_env)}

  let(:request_env) do
    Matterhorn::RequestEnv.new.tap do |env|
      env[:url_builder] = url_builder
    end
  end

  context "#url_options" do
    it "should raise exception" do
      expect{ set_member.url_options(nil) }.to raise_exception
    end
  end

  context "#active_model_serializer" do
    context "default serializer" do
      it "should return base serializer" do
        expect(set_member.active_model_serializer).to eq(Matterhorn::Serialization::LinkSerializer)
      end
    end
    context "configured serializer" do
      let!(:article_class) do
        define_class(:Article, base_class) do
          belongs_to :author
          add_link   :author,
            serializer: ActiveModel::Serializer
        end
      end
      it "should return configured serializer" do
        expect(set_member.active_model_serializer).to eq(ActiveModel::Serializer)
      end
    end
  end

  context "#url_builder" do 
    it "should return request_env[:url_builder]" do
      expect(set_member.url_builder).to eq(request_env[:url_builder])
    end
  end

  context "#resource_class" do
    it "should raise exception when resource is invalid" do
      expect{set_member.resource_class(Hash.new)}.to raise_exception
    end
  end

  context "#nested_member" do 
    it "should return resource" do 
      hash = Hash.new
      expect(set_member.nested_member(hash)).to eq(hash)
    end
  end

end
