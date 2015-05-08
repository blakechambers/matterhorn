require 'spec_helper'


RSpec.describe "links" do
  include ResourceHelpers
  include AuthenticationHelpers

  collection_name "posts"
  resource_name "post"
  resource_class Post
  resource_scope Post.first
  let!(:user) { User.make! } 
  let!(:resource) { resource_class.make!(user_id: user.id) }
  let!(:comments) do 
    3.times.map do
      Comment.make!(post: resource, user: user)
    end
  end


  ie(:content_type)    { expect(headers["Content-Type"]).to include("application/vnd.api+json; charset=utf-8") }
  ie(:utf8)            { expect(headers["Content-Type"]).to include("charset=utf-8") }
  ie(:resource_body)   { expect(data.execute).to be_a(Hash) }

  context "belongs_to" do
    with_request "GET /#{collection_name}/:id/links/user.json" do
      request_path { "/#{collection_name}/#{resource.id}/links/user.json" }

      its_status_should_be 200
      it_should_have_content_length

      it "should provide links section in response" do
        perform_request!
        expect(body[:links][:self].execute).to eq("http://example.org/posts/#{resource.id}/links/user")
        expect(body[:links][:related].execute).to eq("http://example.org/posts/#{resource.id}/user")
      end

      it "should provide data section" do
        perform_request!
        expect(body[:data][:id].execute).to eq(resource.user.id.to_s)
        expect(body[:data][:type].execute).to eq("users")
      end
    end
  end

  context "has_one" do
    with_request "GET /#{collection_name}/:id/links/topic.json" do
      request_path { "/#{collection_name}/#{resource.id}/links/topic.json" }

      it "should provide links section in response" do
        perform_request!

        expect(body[:links][:self].execute).to eq("http://example.org/posts/#{resource.id}/links/topic")
        expect(body[:links][:related].execute).to eq("http://example.org/posts/#{resource.id}/topic")
      end

      it "should provide data section" do
        perform_request!
         expect(body[:data][:id].execute).to eq(resource.topic.id.to_s)
         expect(body[:data][:type].execute).to eq("topics")
      end
    end

  end

  context "has_many" do
    ie(:resource_body)   { expect(data.execute).to be_a(Array) }
    with_request "GET /#{collection_name}/:id/links/comments.json" do
      request_path { "/#{collection_name}/#{resource.id}/links/comments.json" }

      it "should provide links section in response" do
        perform_request!

        expect(body[:links][:self].execute).to eq("http://example.org/posts/#{resource.id}/links/comments")
        expect(body[:links][:related].execute).to eq("http://example.org/posts/#{resource.id}/comments")
      end

      it "should provide data section" do
        perform_request!
        resource.comments.each do |comment|
          comment_data = body[:data].execute.detect{|c| c["id"] == comment.id.to_s}
          expect(comment_data).to eq({"id" => comment.id.to_s, "type" => "comments"})
        end
      end
    end
  end
end
