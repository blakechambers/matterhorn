require 'spec_helper'

RSpec.describe "create" do
  include ResourceHelpers
  include AuthenticationHelpers

  collection_name "posts"
  resource_name "post"
  resource_class Post
  resource_scope Post.first

  let!(:params) { request_params.merge!("data" => resource_params) }
  let(:resource_params) { valid_params }
  let(:valid_params) do
    {
      body: "new body",
      title: "new title"
    }
  end

  its_status_should_be 201
  it_should_have_content_length

  ie(:content_type)  { expect(headers["Content-Type"]).to include(Matterhorn::CONTENT_TYPE)}
  ie(:utf8)          { expect(headers["Content-Type"]).to include("charset=utf-8") }
  ie(:resource_body) { expect(data.execute).to be_a(Hash) }
  ie(:db_changed)    { it_should_create_resource(resource_class.first) }
  ie(:http_location) { expect(headers["Location"]).to eq("http://example.org/#{collection_name}/#{resource_class.first.id}") }

  with_request "POST /#{collection_name}.json"  do

    # TODO: relationship link testing should happen after 0.1.0
    # context "relationship links" do
    #   let(:nested_params) do
    #     {
    #       author: {
    #         id: current_user.id.to_s
    #       }
    #     }
    #   end
    #   let(:create_params) { valid_params.merge!(nested_params) }
    #   it "should create relationships" do
    #     perform_request!
    #     created_post_id = body[top_level_key][:_id].execute
    #     created_post    = Post.find(created_post_id)
    #     expect(body[top_level_key]).to provide(created_post)
    #   end
    # end

    context "when validation errors are present" do
      let(:resource_params) { valid_params.merge(body: nil) }

      its_status_should_be 422

      ie(:resource_body) { "do nothing" }
      ie(:db_changed)    { "do nothing" }
      ie(:http_location) { "do nothing" }

      it "should return errors hash" do
        perform_request!

        expect(body[:errors].execute.count).to eq(1)
        error_detail = body[:errors].first[:detail].execute

        expect(error_detail).to include("body: can't be blank")
      end

    end
  end
end
