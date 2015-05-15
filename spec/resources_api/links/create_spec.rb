# require 'spec_helper'
#
# RSpec.describe "links" do
#   include ResourceHelpers
#   include AuthenticationHelpers
#
#   collection_name "posts"
#   resource_name "post"
#   resource_class Post
#   resource_scope Post.first
#   let!(:user) { User.make! }
#   let!(:resource) { resource_class.make!(user_id: user.id) }
#   let!(:comments) do
#     3.times.map do
#       Comment.make!(post: resource, user: user)
#     end
#   end
#
#   ie(:content_type)    { expect(headers["Content-Type"]).to include("application/vnd.api+json; charset=utf-8") }
#   ie(:utf8)            { expect(headers["Content-Type"]).to include("charset=utf-8") }
#   ie(:resource_body)   { expect(data.execute).to be_a(Hash) }
#
#   context "link does not exist" do
#     with_request "GET /#{collection_name}/:id/links/foo.json" do
#       request_path { "/#{collection_name}/#{resource.id}/links/foo.json" }
#
#       its_status_should_be 404
#     end
#   end
#
#   context "belongs_to" do
#     with_request "POST /#{collection_name}/:id/links/user.json" do
#       request_path { "/#{collection_name}/#{resource.id}/links/user.json" }
#       its_status_should_be 403
#     end
#   end
#
#   context "has_one_to" do
#     with_request "POST /#{collection_name}/:id/links/topic.json" do
#       request_path { "/#{collection_name}/#{resource.id}/links/topic.json" }
#       its_status_should_be 403
#     end
#   end
#
#   context "has_many" do
#     ie(:resource_body)   { expect(data.execute).to be_a(Array) }
#     with_request "POST /#{collection_name}/:id/links/comments.json" do
#       request_path { "/#{collection_name}/#{resource.id}/links/comments.json" }
#
#       its_status_should_be 204
#
#       context "create" do
#         it "should create members"
#         it "should not create duplicates"
#       end
#       context "append" do
#         it "should not create duplicates"
#         it "should append to members"
#       end
#       context "null linkage" do
#         it "should not modify members"
#
#         context "no members exist" do
#           it "should not modifiy members"
#         end
#
#       end
#
#     end
#   end
# end
