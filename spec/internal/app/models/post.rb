class Post
  include Mongoid::Document
  include Mongoid::Timestamps
  include Matterhorn::Links::LinkSupport

  field :title
  field :body
  field :initial_comments_ids, type: Array

  belongs_to :user

  has_many :comments
  has_one  :topic
  has_many :votes
  has_and_belongs_to_many :tags, inverse_of: nil

  vote_scope = proc do |scope_class, set_member, env|
    env[:current_user].votes.all
  end

  add_link :user,
    nested: true

  add_link :comments,
    nested: true

  #add_link :tags,
    #nested: true

  add_link :topic,
    nested: true,
    singleton: true

  add_link :vote,
    relation_name:  :votes,
    singleton:      true,
    scope:          vote_scope,
    nested:         true,
    type:           :has_one

  validates_presence_of :body

  accepts_nested_attributes_for :user, :topic

end
