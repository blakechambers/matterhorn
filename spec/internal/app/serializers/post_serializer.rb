class PostSerializer < BaseSerializer
  attributes :user_id, :body, :initial_comments_ids
end
