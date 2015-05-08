require 'spec_helper'

RSpec.describe "index" do
  include ResourceHelpers
  include AuthenticationHelpers

  collection_name "posts"
  resource_class Post
  resource_scope Post.all

  # NOTE helpers presume presence of either collection or resource variables
  let(:collection) { resource_scope.to_a }

  its_status_should_be 200
  it_should_have_content_length

  ie(:content_type)    { expect(headers["Content-Type"]).to include(Matterhorn::CONTENT_TYPE) }
  ie(:utf8)            { expect(headers["Content-Type"]).to include("charset=utf-8") }
  ie(:collection_body) { expect(data.execute).to be_an(Array) }

  with_request "GET /#{collection_name}.json" do

    it "should provide complete links" do
      resource_class.make!
      perform_request!
    end

    it "should provide items with existing resources" do
      resource = resource_class.make!
      perform_request!

      it_should_have_top_level_data_for_collection
      expect(data.execute.count).to eq(1)
      expect(data).to include_a_provided(resource)
    end

    it "should reject invalid accept types" do
      # rails will take the extension first.  So, we need to unset
      request_path "/#{collection_name}"
      request_envs.merge! "HTTP_ACCEPT" => "invalid/format"

      its_status_should_be 406
      ie(:collection_body) { "do nothing" }
      ie(:link_vote)       { "do nothing" }
      ie(:link_user)     { "do nothing" }
      ie(:link_comments)   { "do nothing" }

      perform_request!

      errors = body[:errors]
      error  = errors.first

      expect(errors.execute.count).to eq(1)
      expect(error[:title].execute).to  eq("action_controller/unknown_format")
      expect(error[:detail].execute).to eq("ActionController::UnknownFormat")
      expect(error[:status].execute).to eq(406)
    end


    context "when requesting inclusions" do

      let!(:users_vote) { Vote.make! user: current_user, post: post }
      let!(:other_vote) { Vote.make! post: post }
      let(:post)        { Post.make! user: current_user }

      it "should included scoped votes" do
        # pending "INCLUDES"

        request_params.merge! include: "vote"
        perform_request!

        expect(body[:includes]).to include_a_provided(users_vote)
      end

      it "should include scoped authors" do
        request_params.merge! include: "author"
        perform_request!

        expect(body[:includes]).to include_a_provided(current_user)
      end

    end

    context "when paging" do

      let!(:all_posts){
        5.times.map { resource_class.make! }
      }

      let(:ordered_posts) { Post.order_by(:created_at.desc).all }

      it "should allow a page param" do
        request_params.merge! offset: "1"
        perform_request!
        expect(data).to provide(ordered_posts[1..-1])
      end

      it "should allow a per_page param" do
        request_params.merge! limit: "1"
        perform_request!
        expect(data).to provide(ordered_posts[0..0])
      end

      it "should allow a page and per_page param" do
        request_params.merge! limit: "2", offset: 2
        perform_request!
        expect(data).to provide(ordered_posts[2..3])
      end

      it "should provide a self link" do
        request_params.merge! limit: "1"
        perform_request!
        expect(body[:links][:self].execute).to eq("http://example.org/posts?limit=1")
      end

      it "should provide a next link" do
        request_params.merge! limit: "1"
        perform_request!
        expect(body[:links][:next].execute).to eq("http://example.org/posts?limit=1&offset=1")
      end

      it "should provide a prev link" do
        request_params.merge! limit: "1", offset: "1"
        perform_request!
        expect(body[:links][:prev].execute).to eq("http://example.org/posts?limit=1&offset=0")
      end

    end

    context "when ordering" do
      let!(:resources) { [ resource_class.make!(created_at: Time.zone.now ),
                         resource_class.make!(created_at: Time.zone.now - 100),
                         resource_class.make!(created_at: Time.zone.now - 1000)
                       ]}

      it "should order by provided params" do
        request_params.merge! order: "oldest"
        perform_request!

        expect(body[:links][:self].execute).to eq("http://example.org/posts?order=oldest")
        expect(data.execute.map{|c| c["id"] }).to eq(resource_class.order(:created_at.asc).map(&:id).map(&:to_s))
      end

      it "should provide links for orders" do
        perform_request!

        expect(body[:orders][:recent].execute).to eq("http://example.org/posts?order=recent")
        expect(body[:orders][:oldest].execute).to eq("http://example.org/posts?order=oldest")

      end

      it "should raise an error for invalid order" do
        request_params.merge! order: "invalid_order"

        ie(:status)          { "do nothing" }
        ie(:content_length)  { "do nothing" }
        ie(:content_type)    { "do nothing" }
        ie(:utf8)            { "do nothing" }
        ie(:collection_body) { "do nothing" }
        ie(:link_vote)       { "do nothing" }
        ie(:link_user)     { "do nothing" }
        ie(:link_comments)   { "do nothing" }

        expect{ perform_request! }.to raise_exception(Matterhorn::Ordering::InvalidOrder)

      end

    end
  end
end
