class Tag
  include Mongoid::Document
  include Matterhorn::Links::LinkSupport

  field :name

  belongs_to :post

  validates_presence_of :name

end
