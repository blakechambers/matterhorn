require 'spec_helper'

RSpec.describe "multi ids resources" do
  include ResourceHelpers
  include AuthenticationHelpers

  collection_name "posts"  
  resource_class Post
  resource_scope Post.all

  # NOTE helpers presume presence of either collection or resource variables
  let(:collection) { resource_scope.to_a }
  let(:posts) do 
    4.times.map do 
      post = Post.make!
      Comment.make! post: post
      post
    end
  end
  let!(:other_posts) do
    2.times.map do
      Post.make!
    end
  end
  let(:collection_ids) do 
    ids = posts.map do |p|
      p.id.to_s 
    end
    ids.join(',')
  end

  context 'with_request "GET /#[collection_name}/:id1,:id3.json"' do

    its_status_should_be 200
    it_should_have_content_length

    ie(:content_type)    { expect(headers["Content-Type"]).to include("application/json") }
    ie(:utf8)            { expect(headers["Content-Type"]).to include("charset=utf-8") }
    ie(:collection_body) { expect(body[top_level_key].execute).to be_an(Array) }

    it "should return a collection of resources with ids requests" do
      request_method "GET"
      request_path "/#{collection_name}/#{collection_ids}.json"
      perform_request!

      response_ids = body[top_level_key].execute.collect {|ea| ea["_id"] }
      expect(response_ids.count).to eq(4)
      other_posts.each do |p|
        expect(response_ids).to_not include(p.id.to_s)
      end
    end
  end

  #let!(:users_votes)  { Vote.make! user: current_user, post: post }
  #let!(:other_votes)  { Vote.make! post: post }
  #let(:post) { Post.make! }

  let(:posts) do 
    4.times.map do 
      p = Post.make!
      Comment.make!(post: p)
      p
    end
  end
  let!(:other_posts) do
    2.times.map do
      p = Post.make!
      Comment.make!(post: p)
      p
    end
  end
  let(:post_ids) { posts.map{|p| p.id} }
  let(:other_post_ids) { other_posts.map{|p| p.id} }
  let(:collection_ids) do 
    post_ids.map{|ea| ea.to_s}.join(',')
  end
  let(:comments) { Comment.in(post: post_ids) }
  let(:other_comments) { Comment.in(post: other_post_ids) }

  context 'with_request "GET /#{collection_name}/:id1,:id4/:nested_collection.json"' do

    it "should use multi-ids to scope relationship" do
      request_method "GET"
      request_path "/#{collection_name}/#{collection_ids}/comments.json"
      perform_request!

      ie(:resource_body)   { expect(body[top_level_key].execute).to be_a(Array) }
      response_ids = body[top_level_key].execute.collect {|ea| ea["_id"] }
      expect(response_ids.count).to eq(4)
      comments.each do |p|
        expect(response_ids).to include(p.id.to_s)
      end
      other_comments.each do |p|
        expect(response_ids).to_not include(p.id.to_s)
      end
    end

  end

end
