Rails.application.routes.draw do
  resources :issues
  resources :users
  root 'application#hello'
end