Rails.application.routes.draw do
  resources :posts do
    resource  :author
    resource  :topic
    resource  :vote
    resources :comments
    resources :links
    resources :tags
  end

  resources :comments
  resources :tags
  resources :topics
  resources :authors
  resources :votes
  resources :users
end
