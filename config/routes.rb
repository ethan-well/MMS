Rails.application.routes.draw do
  ActiveAdmin.routes(self)
  get 'password_resets/create'

  get 'password_resets/edit'

  get 'password_resets/update'

  root 'orders#index'

  resources :users
  resources :sessions
  resources :orders
  resources :goods

  get '/login', to: 'sessions#new', as: 'login'
  post '/logout', to: 'sessions#destroy', as: 'logout'
end
