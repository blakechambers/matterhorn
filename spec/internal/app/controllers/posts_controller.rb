class PostsController < Matterhorn::Base
  include Matterhorn::Resources
  include FakeAuth
  include Matterhorn::Ordering
  include Matterhorn::Paging

  allow_order :recent, :created_at.desc
  allow_order :oldest, :created_at.asc

  default_order :recent
  resources!

  add_env :current_user

  paginates_with Matterhorn::Paging::Default

  allow_resource_params \
    :body, :title, user: [ :id ], topic: [:id, :name]
end
