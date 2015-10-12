class SearchTopicsController < Matterhorn::Base
  include Matterhorn::Resources
  include FakeAuth
  include Matterhorn::Paging

  paginates_with Matterhorn::Paging::PerPage

  resources!

  def collection
    Topic.all
  end
end
