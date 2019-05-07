Rails.application.routes.draw do
  
  resources :sessions, only: [:create, :destroy]
  resource :home, only: [:show]
  resources :issues
  resources :users
  resources :comments
  resources :attachments
  
  get 'auth/:provider/callback', to: "sessions#create"
  get 'auth/failure', to: redirect('/')
  get 'signout', to: 'sessions#destroy', as: 'signout'

  get 'home/show'

  post '/issues/:id/watch' => "issues#watch", as: :watch
  post '/issues/:id/unwatch' => "issues#unwatch", as: :unwatch
  
  post '/issues/:id/vote' => "issues#vote", as: :vote
  post '/issues/:id/unvote' => "issues#unvote", as: :unvote
  
  #root 'issues#index'
  root to: "home#show"
  
  
  get '/issues/:Issue_id/comments' => "comments#getByIssue", as: :getByIssue
  post '/issues/:Issue_id/comments' => "comments#postOnIssue", as: :postOnIssue
  get '/issues/:Issue_id/attachments' => "attachments#findByIssue", as: :findByIssue
  
  namespace :api, defaults: { format: "json" } do
    namespace :v1 do
      resources :issues
      resources :users
      resources :comments
      resources :attachments
    end
  end

end

