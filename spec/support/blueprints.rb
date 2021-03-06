require 'machinist/mongoid'


Comment.blueprint do
  user  { User.make! }
  post  { Post.make! }
  text  { "comment" }
end


Post.blueprint do
  author  { User.make! }
  body    { "body" }
  topic   { Topic.make! }
end

User.blueprint do
  auth_token  { "token" }
  name        { "name" }
end

Topic.blueprint do
  name    { "name" }
end

Vote.blueprint do
  user  { User.make! }
  post  { Post.make! }
  score { 1 }
end
