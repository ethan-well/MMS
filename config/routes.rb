Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  devise_for :users, controllers: { sessions: 'users/sessions', registrations: 'users/registrations', confirmations: 'confirmations', passwords: 'users/passwords' }

  ActiveAdmin.routes(self)
  get 'password_resets/create'

  get 'password_resets/edit'

  get 'password_resets/update'

  root to: 'orders#index'

  devise_scope :user do
    get 'sign_in', to: 'users/sessions#new'
    get 'sign_out', to: 'users/sessions#destroy'
  end

  resources :orders do
    member do
      post 'cancel'
      post 'finished'
    end
  end

  resources :goods do
    member do
      get 'get_price'
    end
  end

  resources :infos

  resources :admins do
    collection do
      get 'goods'
      get 'notices'
      get 'orders'
      get 'users'
      post 'create_goods'
    end
  end

  resources :notices, only: [:index, :update]

  resources :special_prices
end
