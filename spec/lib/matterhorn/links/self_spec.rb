require "spec_helper"
require "class_builder"
require "action_dispatch/routing"

RSpec.describe "Matterhorn::Links::Self" do
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

  let(:article)    { article_class.create }
  let(:set_member) { link_set[:self] }
  let(:self_config) { Matterhorn::Links::LinkConfig.new(nil, :self, type: :self) }

  let(:link_set) do
    Matterhorn::Links::LinkSet.new({self: self_config}, context: article, request_env: request_env)
  end

  it "should set relation to type Links::Self" do
    expect(set_member).to be_kind_of(Matterhorn::Links::Self)
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

    context "when context: criteria" do
      let(:link_context) { Article.all }

      it { expect(url).to eq("http://example.org/articles") }
      it { expect(serialized).to eq("http://example.org/articles") }
    end

  end
end
