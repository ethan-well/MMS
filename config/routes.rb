Rails.application.routes.draw do
  get 'password_resets/create'

  get 'password_resets/edit'

  get 'password_resets/update'

  root 'users#index'

  resources :users
  resources :sessions
  resources :cards

  get '/example', to: 'them#index'

  get '/login', to: 'sessions#new', as: 'login'
  post '/logout', to: 'sessions#destroy', as: 'logout'
end
