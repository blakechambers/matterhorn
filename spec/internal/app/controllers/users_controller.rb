class UsersController < Matterhorn::Base
  include Matterhorn::Resources
  include FakeAuth

  resources!
  belongs_to :post

  allow_collection_params \
    :include

end
