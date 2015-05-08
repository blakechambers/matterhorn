require 'spec_helper'

RSpec.describe "Matterhorn::Serialization::LinkSerializer" do

  include ClassBuilder
  include UrlTestHelpers

  routes_config do
    resources :articles do
      resources :links
      resource  :person
      resource  :opines
      resource  :category
    end
    resources :persons
  end

  let!(:base_class) do
    define_class(:BaseKlass) do
      include Mongoid::Document
      include Matterhorn::Links::LinkSupport
    end
  end

  let!(:article_class) do
    define_class(:Article) do
      include Mongoid::Document
      include Matterhorn::Links::LinkSupport

      has_one    :category
      has_many   :opines
      belongs_to :person

      add_link   :person,
        nested: true
      add_link :opines,
        nested: true
      add_link   :category,
        nested: true

    end
  end

  let!(:person_class) do
    define_class(:Person) do
      include Mongoid::Document
      include Matterhorn::Links::LinkSupport
      field :name
    end
  end
  let!(:opines_class) do
    define_class(:Opine) do
      include Mongoid::Document
      include Matterhorn::Links::LinkSupport
      field :blurb
      belongs_to :article
    end
  end
  let!(:category_class) do
    define_class(:Category) do
      include Mongoid::Document
      include Matterhorn::Links::LinkSupport
      belongs_to :article, foreign_key: :article_id
      field :key
    end
  end

  let!(:serializer_class) do
    Matterhorn::Serialization::LinkSerializer
  end

  let(:request_env) do
    Matterhorn::RequestEnv.new.tap do |env|
      env[:url_builder] = url_builder
    end
  end

  let!(:person)  { person_class.create(name: "Jimbob") }
  let!(:category) { category_class.create(key: 'tech') }
  let(:article)  do
    a = article_class.create(person: person)
    a.category = category
    a 
  end

  let(:opines) do 
    3.times.map do 
      article.opines << opines_class.create(blurb: "hey!")
    end
  end

  let(:serializer) { Matterhorn::Serialization::LinkSerializer.new(set_member, request_env: request_env) }
  let(:parsed_serialized) { SerialSpec::ParsedBody.new(serializer.to_json) }

  context "belongs_to" do
    let(:set_member) { article.links[:person] }

    it "should have data section" do 
      expect(parsed_serialized[:data][:type].execute).to eq("people")
      expect(parsed_serialized[:data][:id].execute).to eq(article.person.id.to_s)
    end

    it "should have top level self link" do
      expect(parsed_serialized[:links][:self].execute).to eq("http://example.org/articles/#{article.id.to_s}/links/person")
    end

    it "should have related top level" do
      expect(parsed_serialized[:links][:related].execute).to eq("http://example.org/articles/#{article.id}/person")
    end

  end

  context "has_one" do
    let(:set_member) { article.links[:category] }
    it "should have data section" do 
      expect(parsed_serialized[:data][:type].execute).to eq("categories")
      expect(parsed_serialized[:data][:id].execute).to eq(article.category.id.to_s)
    end

    it "should have top level self link" do
      expect(parsed_serialized[:links][:self].execute).to eq("http://example.org/articles/#{article.id.to_s}/links/category")
    end

    it "should have related top level" do
      expect(parsed_serialized[:links][:related].execute).to eq("http://example.org/articles/#{article.id}/category")
    end
  end

  context "has_many" do
    let(:set_member) { article.links[:opines] }

    it "should have data section with opines" do 
      article.opines.each do |opine|
        opine_data = parsed_serialized[:data].execute.detect{|c| c["id"] == opine.id.to_s}
        expect(opine_data).to eq({"id" => opine.id.to_s, "type" => "opines"})
      end
    end

    it "should have top level self link" do
      expect(parsed_serialized[:links][:self].execute).to eq("http://example.org/articles/#{article.id.to_s}/links/opines")
    end

    it "should have related top level" do
      expect(parsed_serialized[:links][:related].execute).to eq("http://example.org/articles/#{article.id}/opines")
    end
  end
end
