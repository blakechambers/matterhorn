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
#
#   context "link does not exist" do
#     with_request "DELETE /#{collection_name}/:id/links/foo.json" do
#       request_path { "/#{collection_name}/#{resource.id}/links/foo.json" }
#
#       its_status_should_be 404
#     end
#   end
#
#   context "belongs_to" do
#     with_request "DELETE /#{collection_name}/:id/links/user.json" do
#       request_path { "/#{collection_name}/#{resource.id}/links/user.json" }
#
#       its_status_should_be 204
#       it_should_have_content_length
#
#     end
#   end
#
#   context "has_one" do
#     with_request "DELETE /#{collection_name}/:id/links/topic.json" do
#       request_path { "/#{collection_name}/#{resource.id}/links/topic.json" }
#     end
#
#   end
#
#   context "has_many" do
#     ie(:resource_body)   { expect(data.execute).to be_a(Array) }
#     with_request "DELETE /#{collection_name}/:id/links/comments.json" do
#       request_path { "/#{collection_name}/#{resource.id}/links/comments.json" }
#     end
#   end
# end
