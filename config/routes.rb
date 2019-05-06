Rails.application.routes.draw do
  
  get 'auth/:provider/callback', to: "sessions#create"
  get 'auth/failure', to: redirect('/')
  get 'signout', to: 'sessions#destroy', as: 'signout'

  resources :sessions, only: [:create, :destroy]
  resource :home, only: [:show]
  
  get 'home/show'

  resources :issues
  resources :users
  resources :comments
  resources :attachments
  
  post '/issues/:id/watch' => "issues#watch", as: :watch
  post '/issues/:id/unwatch' => "issues#unwatch", as: :unwatch
  
  post '/issues/:id/vote' => "issues#vote", as: :vote
  post '/issues/:id/unvote' => "issues#unvote", as: :unvote
  
  #root 'issues#index'
  root to: "home#show"
  
  get '/comments/issue/:Issue_id' => "comments#getByIssue", as: :getByIssue
  #post '/comments/issue/Issue_id' => "comments#postOnIssue", as: :postOnIssue
  put '/api/comments/:comment_id' => "comments#apiGetComment", as: :apiGetComment
  
end 

