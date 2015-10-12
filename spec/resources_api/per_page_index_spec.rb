require 'spec_helper'

RSpec.describe "index" do
  include ResourceHelpers
  include AuthenticationHelpers

  collection_name "topics"
  resource_class Topic

  let!(:params) { request_params.merge! query_text: "jon" } 

  # NOTE helpers presume presence of either collection or resource variables
  let(:collection) { resource_scope.to_a }

  its_status_should_be 200
  it_should_have_content_length

  ie(:content_type)    { expect(headers["Content-Type"]).to include(Matterhorn::CONTENT_TYPE) }
  ie(:utf8)            { expect(headers["Content-Type"]).to include("charset=utf-8") }
  ie(:collection_body) { expect(data.execute).to be_an(Array) }

  with_request "GET /search/topics.json" do

    it "should provide items with existing resources" do
      resource = resource_class.make!
      perform_request!

      expect(data.execute.count).to eq(1)
      expect(data).to include_a_provided(resource)
    end

    it "should reject invalid accept types" do
      # rails will take the extension first.  So, we need to unset
      request_path "/search/topics"
      request_envs.merge! "HTTP_ACCEPT" => "invalid/format"

      its_status_should_be 406
      ie(:collection_body) { "do nothing" }

      perform_request!

      errors = body[:errors]
      error  = errors.first

      expect(errors.execute.count).to eq(1)
      expect(error[:title].execute).to  eq("action_controller/unknown_format")
      expect(error[:detail].execute).to eq("ActionController::UnknownFormat")
      expect(error[:status].execute).to eq(406)
    end

    context "when paging" do

      let!(:all_posts){
        5.times.map { Topic.make! }
      }

      let(:ordered_posts) { Topic.all }

      it "should allow a page param" do
        request_params.merge! per_page: "1", page: "2"
        perform_request!
        expect(data).to provide(ordered_posts[1..1])
      end

      it "should allow a per_page param" do
        request_params.merge! per_page: 2
        perform_request!
        expect(data).to provide(ordered_posts[0..1])
      end

      it "should provide a self link" do
        request_params.merge! per_page: "1"
        perform_request!
        expect(body[:links][:self].execute).to eq("http://example.org/topics?per_page=1")
      end

      it "should provide a next link" do
        request_params.merge! per_page: "1"
        perform_request!
        expect(body[:links][:next].execute).to eq("http://example.org/topics?page=2&per_page=1")
      end

      it "should provide a prev link" do
        request_params.merge! per_page: "1", page: "2"
        perform_request!
        expect(body[:links][:prev].execute).to eq("http://example.org/topics?page=1&per_page=1")
      end

    end
  end
end
