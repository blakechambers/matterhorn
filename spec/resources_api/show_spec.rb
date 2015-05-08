require 'spec_helper'

RSpec.describe "show" do
  include ResourceHelpers
  include AuthenticationHelpers

  collection_name "posts"
  resource_name "post"
  resource_class Post
  resource_scope Post.first
  let(:resource) { resource_class.make! initial_comments_ids: [1,2,3] }

  with_request "GET /#{collection_name}/:id.json" do
    request_path { "/#{collection_name}/#{resource.id}.json" }

    its_status_should_be 200
    it_should_have_content_length

    ie(:content_type)    { expect(headers["Content-Type"]).to include(Matterhorn::CONTENT_TYPE)}
    ie(:utf8)            { expect(headers["Content-Type"]).to include("charset=utf-8") }
    ie(:resource_body)   { expect(data.execute).to be_a(Hash) }

    it "should provide item with existing resources" do
      perform_request!
      it_should_have_top_level_data_for_resource
      it_should_respond_with_resource
    end

    it "should provide links object in response" do
      request_params.merge! include: "user"
      perform_request!

      expect(body[:links].execute).to be_kind_of(Hash)
      expect(body[:links].execute).to be_kind_of(Hash)
    end

    context "when defining a custom scope" do

      let!(:users_votes)  { Vote.make! user: current_user, post: resource }
      let!(:other_votes)  { Vote.make! post: resource }

      it "should included scoped votes" do
        request_params.merge! include: "vote"
        perform_request!

        expect(body[:includes].execute.count).to eq(1)
        expect(body[:includes].first[:id].execute).to eq(users_votes.id.to_s)
      end

      it "should include scoped users" do
        request_params.merge! include: "user"
        perform_request!

        expect(body[:includes].execute.count).to eq(1)
        expect(body[:includes].first[:id].execute).to eq(resource.user_id.to_s)
      end

      it "should provide complete links" do
        perform_request!
        links = data[:links]

        # TODO: this should be swapped to use a nested route, e.g. http://example.org/posts/{posts._id}/votes
        # TODO: this is wrong these are appearing under "data/links" should be at the top level "links"
        vote_linkage      = {"linkage"=>{"post_id"=> resource.id.to_s, "type"=>"votes"}, "related"=>"http://example.org/posts/#{resource.id.to_s}/vote"}
        user_linkage    = {"linkage"=>{"id"=>resource.user_id.to_s, "type"=>"users"}, "related"=>"http://example.org/posts/#{resource.id.to_s}/user"}
        comments_linkage  = {"linkage"=>{"post_id"=> resource.id.to_s, "type"=>"comments"}, "related"=>"http://example.org/posts/#{resource.id.to_s}/comments"}
        topic_linkage     = {"linkage"=> {"post_id"=> resource.id.to_s, "type"=>"topics"}, "related"=>"http://example.org/posts/#{resource.id.to_s}/topic"}

        expect(links[:vote].execute).to     eq(vote_linkage)
        expect(links[:user].execute).to   eq(user_linkage)
        expect(links[:comments].execute).to eq(comments_linkage)
        expect(links[:topic].execute).to    eq(topic_linkage)
        # expect(links[:initial_comments].execute).to eq({"linkage"=>{"id"=>"1,2,3", "type"=>"comments"}, "related"=>"http://example.org/comments/1,2,3"})
      end

    end

    # TODO: this is actually inaccurate to the spec, so I'm commenting it out
    #       for now. See https://github.com/blakechambers/matterhorn/pull/63 for
    #       more information.
    #
    # context "with no user" do
    #   let(:resource) { resource_class.make! user: nil, initial_comments_ids: [1,2,3] }
    #
    #   it "should not return the user link if the user id is not in the response" do
    #     perform_request!
    #
    #     expect(data[:user_id].execute).to be_nil
    #     expect(data[:links][:user][:linkage].execute).to be_nil
    #     expect(data[:links][:user][:related].execute).to be_nil
    #   end
    #
    # end
  end
end
