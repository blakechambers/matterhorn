class PostSerializer < BaseSerializer
  attributes :author_id, :body, :initial_comments_ids
end
