Rails.application.routes.draw do
  get 'password_resets/create'

  get 'password_resets/edit'

  get 'password_resets/update'

  root 'users#index'
  resources :users
  get '/example', to: 'them#index'
end
