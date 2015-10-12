class Topic
  include Mongoid::Document
  include Matterhorn::Links::LinkSupport
  include Kaminari::MongoidExtension::Document

  field :name

  belongs_to :post

  validates_presence_of :name

end
