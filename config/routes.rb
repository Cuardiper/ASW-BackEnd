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
  
  post '/issues/:id/watch' => "issues#watch", as: :watch
  post '/issues/:id/unwatch' => "issues#unwatch", as: :unwatch
  
  #root 'issues#index'
  root to: "home#show"
end 

