module Member
  class API < Grape::API
    format :json

    helpers do
      def authenticate!(user_name, password)
        u = User.find_by_name(user_name)
        error!({result: 'failed', message: '用户不存在！'}, 404 ) unless u.present?
        error!({result: 'failed', message: '401 Unauthorized'}, 401) unless u.encrypted_password == password
      end
    end

    resource :member do
      # api/member/balance
      desc 'Return user info'
      params do
        requires :username, type: String, desc: 'User name'
        requires :password, type: String, desc: 'password'
      end
      post :balance do
        u = authenticate!(params[:username], params[:password])
        u.balance
        {
          result: 'success',
          message: '查询成功',
          username: u.user_name,
          level:  u.level_id,
          email: u.email,
          sign_up: u.created_at,
          balance: u.balance
         }
      end

      desc 'Return order status'
      params do
        requires :username, type: String, desc: 'User name'
        requires :password, type: String, desc: 'password'
        requires :id, type: Integer, desc: 'order id'
      end
      post :get_order_info do
        begin
          u = authenticate!(params[:username], params[:password])
          order = u.order.find(params[:id])

          { result: 'success',
            message: '查询订单信息成功',
            order_id: order.id,
            status: order.status,
            order_time: order.created_at,
            goods: order.goods.name,
            goods_num: order.count,
            total_price: order.total_price,
            account: order.account,
            remark: order.remark,
            start_num: order.start_num,
            aims_num: order.aims_num,
            current_num: order.current_num
          }
        rescue => ex
          {result: 'failed', message: ex.message}
        end
      end

      desc 'Return goods info'
      params do
        requires :username, type: String, desc: 'User name'
        requires :password, type: String, desc: 'password'
        requires :id, type: Integer, desc: 'order id'
      end
      post :get_goods_info do
        begin
          authenticate!(params[:username], params[:password])
          goods = Goods.find(params[:id])
          { result: 'success',
            message: '查询商品信息',
            name: goods.name,
            price: goods.price
          }
        rescue => ex
          { result: 'failed', message: ex.message }
        end
      end

      desc 'Return all goods info'
      params do
        requires :username, type: String, desc: 'User name'
        requires :password, type: String, desc: 'password'
      end
      post :get_all_goods_info do
        all_goods = []
        begin
          Goods.all.each do |goods|
            goods_info = {
              id: goods.id,
              name: goods.name,
              price: goods.price
            }

            all_goods << goods_info
          end
          { result: 'success', data: all_goods}
        rescue => ex
          { result: 'failed', message: ex.message }
        end
      end

      desc 'Inset order'
      params do
        requires :username, type: String, desc: 'User name'
        requires :password, type: String, desc: 'password'
        requires :goods_id, type: Integer, desc: 'goods id'
        requires :count, type: Integer, desc: 'goods count'
        requires :remark, type: String, desc: 'remark'
      end
      post :insert_order do
        u = authenticate!(params[:username], params[:password])
        begin
          goods = Goods.find(params[:goods_id])

          price_current = goods.get_current_price(u.level_id)
          count = params[:count].to_i
          total_price =  price_current * count
          Order.transaction do
            raise "本次需要支付#{total_price}元，余额不足，请充值后再下单" if u.balance < total_price
            order =  u.orders.create(
              price_current: price_current,
              count: count,
              total_price: total_price,
              start_num: params[:start_num],
              aims_num: params[:aims_num],
              current_num: params[:current_num])
            u.update_attribute(:balance, u.balance - total_price)
          end
          {
            result: 'success',
            message: '下单成功',
            id: order.id,
            cost: order.total_price,
            balance: u.balance
          }
        rescue => ex
          { result: 'failed', message: ex.message }
        end
      end

      desc 'set order status'
      params do
        requires :username, type: String, desc: 'User name'
        requires :password, type: String, desc: 'password'
        requires :id, type: Integer, desc: 'Order id'
        requires :states, type: Integer, desc: 'order states'
      end
      post :set_order_state do
        u = authenticate!(params[:username], params[:password])
        begin
          raise '权限不够' unless u.admin
          order = u.orders.find(params[:id])
          raise '订单信息不存在' unless order.present?
          order.update_attribute(:status, params[:status])

          { result: 'success', message: '状态更新成功' }
        rescue =>ex
          { result: 'failed', message: ex.message }
        end
      end

      desc 'get orders info'
      params do
        requires :username, type: String, desc: 'User name'
        requires :password, type: String, desc: 'password'
        requires :states, type: Integer, desc: 'order states'
        requires :goods_id, type: Integer, desc: 'order states'
      end
      post :get_order_info_throught_goods_id do
        begin
          u = authenticate!(params[:username], params[:password])
          raise '权限不够' unless u.admin
          goods = Goods.find(params[:goods_id])
          raise '类型不存在' unless goods.present?
          orders = goods.orders.order('created_at desc').limit(params[:num])
          all_info = []
          orders.each do |order|
            info = {
                    order_id: order.id,
                    status: order.status,
                    order_time: order.created_at,
                    total_price: order.total_price,
                    account: order.account,
                    remark: order.remark,
                    start_num: order.start_num,
                    aims_num: order.aims_num,
                    current_num: order.current_num
                  }
            all_info << info
          end
          { result: 'success', order_count: orders.count, data: all_info }
        rescue =>ex
          { result: 'failed', message: ex.message }
        end
      end

      desc 'Refund'
      params do
        requires :username, type: String, desc: 'User name'
        requires :password, type: String, desc: 'password'
        requires :id, type: Integer, desc: 'order id'
      end
      post :redund do
        begin
          u = authenticate!(params[:username], params[:password])
          raise '权限不够' unless u.admin
          order = Order.find(params[:id])
          raise '订单不存在' unless order.present?
          raise '订单状态异常不能退款' unless order.status == 'Waiting'
          Order.transaction do
            user = order.user
            user.update_attribute(:balance, user.balance + order.total_price)
            order.update_attribute(:status, 'Refund')
          end
          { result: 'success', message: '退款成功' }
        rescue => ex
          { result: 'failed', message: '退款失败' }
        end
      end

    end

  end
end
