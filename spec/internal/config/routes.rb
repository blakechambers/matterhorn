Rails.application.routes.draw do
  resources :posts do
    resource  :user
    resource  :topic
    resource  :vote
    resources :comments
    resources :links
    resources :tags
  end

  resources :comments
  resources :tags
  resources :topics
  resources :users
  resources :votes
end
