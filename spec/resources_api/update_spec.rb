require 'spec_helper'

RSpec.describe "update" do
  include ResourceHelpers
  include AuthenticationHelpers

  collection_name "posts"
  resource_name   "post"
  resource_class  Post

  request_path { "/#{collection_name}/#{existing_resource.id}.json" }
  let!(:params) { request_params.merge! data: resource_params }

  let(:existing_resource) { Post.make!(body: "body") }
  let(:resource_params)   { { body: "new body" } }

  its_status_should_be 200
  it_should_have_content_length

  ie(:content_type)  { expect(headers["Content-Type"]).to include(Matterhorn::CONTENT_TYPE)}
  ie(:utf8)          { expect(headers["Content-Type"]).to include("charset=utf-8") }
  ie(:resource_body) { expect(body[top_level_key].execute).to be_a(Hash) }
  ie(:db_changed)    { expect(existing_resource.reload.body).to eq("new body") }

  context "resources!" do
    # with_request "PATCH /#{collection_name}/:id.json"
    # with_request "PUT   /#{collection_name}/:id.json"
  end

  context "resource!" do
    resource_name   "topic"
    resource_class  Topic
    request_path { "/#{collection_name}/#{existing_parent.id}/topic.json" }

    let!(:existing_resource) { Topic.make! }
    let(:existing_parent)    { Post.make! topic: existing_resource }

    before do
      # this is a little complicated by the HABTM relationships.
      @topic = Topic.make!
    end

    let(:resource_params)   { { name: "new name" } }

    ie(:db_changed) { expect(existing_resource.reload.name).to eq("new name") }

    with_request "PUT   /#{collection_name}/:id/topic.json"
    with_request "PATCH /#{collection_name}/:id/topic.json"
  end
end
