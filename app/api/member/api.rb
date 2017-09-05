module Member
  class API < Grape::API
    format :json

    helpers do
      def authenticate!(user_name, password)
        u = User.find_by_name(user_name)
        error!({result: false, message: '用户不存在！'}, 404 ) unless u.present?
        error!({result: false, message: '401 Unauthorized'}, 401) unless u.encrypted_password == password
      end
    end

    resource :member do

      # api/member/balance
      desc 'Return user balance'
      params do
        requires :username, type: String, desc: 'User name'
        requires :password, type: String, desc: 'password'
      end

      post :balance do
        u = authenticate!(params[:username], params[:password])
        u.balance
        { result: true, balance: balance }
      end
    end


  end
end
