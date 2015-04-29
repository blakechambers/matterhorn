class Vote
  include Mongoid::Document

  field :score

  belongs_to :user
  belongs_to :post

  validates_presence_of :score
  validates_numericality_of :score

end
