Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  devise_for :users, controllers: { sessions: 'users/sessions', registrations: 'users/registrations', confirmations: 'confirmations', passwords: 'users/passwords' }

  ActiveAdmin.routes(self)

  mount Member::API => '/api'
  get 'password_resets/create'

  get 'password_resets/edit'

  get 'password_resets/update'

  root to: 'infos#index'

  devise_scope :user do
    get 'sign_in', to: 'users/sessions#new'
    get 'sign_out', to: 'users/sessions#destroy'
  end

  resources :orders do
    member do
      post 'cancel'
      post 'finished'
      post 'admin_change_status'
    end
    collection do
      get 'purchase_history'
      post 'manage_on_sale'
    end
  end

  resources :goods do
    member do
      get 'get_price'
    end
  end

  resources :infos do
    collection do
      get 'l_infos'
      post 'reset_my_password'
    end
  end

  resources :admins do
    collection do
      get 'goods'
      get 'notices'
      get 'orders'
      get 'users'
      post 'create_goods'
      get 'expenses'
      get 'edit_user'
      post 'update_user'
      get 'types'
      post 'can_log_in_or_invite'
      get 'edit_user_password'
      post 'update_user_password'
      get 'sale_infos'
    end
  end

  resources :notices do
    collection do
      post 'alert_show'
    end
  end

  resources :special_prices do
    collection do
      get 'user_special_prices'
      get 'goods_special_prices'
      post 'create_or_update'
    end
  end

  resources :levels, only: [:index, :edit, :update]

  resources :system_settings, only: [:update]

  resources :recharge_records, only: [:index, :new] do
    collection do
      get 'call_back'
    end
  end

  resources :deduct_percentages, only: [:index]

  resources :h_set_prices do
    collection do
      post 'create_or_update'
    end
  end

  resources :invites, only: [:index]

  resources :goods_types
end
