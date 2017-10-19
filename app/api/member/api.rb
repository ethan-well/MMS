module Member
  class API < Grape::API
    format :json

    helpers do
      def authenticate!(user_email, password)
        u = User.find_by_email(user_email)
        error!({result: 'failed', message: '用户不存在！'}, 404 ) unless u.present?
        error!({result: 'failed', message: '401 Unauthorized'}, 401) unless u.md5_password == password
        u
      end
    end

    resource :member do
      # api/member/balance
      desc 'Return user info'
      params do
        requires :user_email, type: String, desc: 'User email'
        requires :password, type: String, desc: 'password'
      end
      post :balance do
        u = authenticate!(params[:user_email], params[:password])
        {
          result: 'success',
          message: '查询成功',
          username: u.name,
          level:  u.level_id,
          email: u.email,
          sign_up: u.created_at,
          balance: u.balance
         }
      end

      desc 'Return order info'
      params do
        requires :user_email, type: String, desc: 'User email'
        requires :password, type: String, desc: 'password'
        requires :id, type: String, desc: 'order id'
      end
      post :get_order_info do
        begin
          u = authenticate!(params[:user_email], params[:password])
          order = u.orders.find_by_identification_code(params[:id])
          raise '订单不存在' unless order.present?

          { result: 'success',
            message: '查询订单信息成功',
            order_id: order.identification_code,
            status: order.status,
            order_time: order.created_at,
            goods: order.goods.try(:name),
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

      desc 'get my orders info'
      params do
        requires :user_email, type: String, desc: 'User email'
        requires :password, type: String, desc: 'password'
      end
      post :get_my_all_orders_info do
        begin
          u = authenticate!(params[:user_email], params[:password])
          orders = u.orders
          orders = orders.where(goods_id: params[:goods_id]) if params[:goods_id].present?
          infos = []
          orders.each do |order|
            info =
              {
                order_id: order.identification_code,
                status: order.status,
                order_time: order.created_at,
                goods: order.goods.try(:name),
                goods_num: order.count,
                total_price: order.total_price,
                account: order.account,
                remark: order.remark,
                start_num: order.start_num,
                aims_num: order.aims_num,
                current_num: order.current_num
              }
            infos << info
          end

          { result: 'success',
            message: '查询订单信息成功',
            data: infos
          }
        rescue => ex
          {result: 'failed', message: ex.message}
        end
      end

      desc 'Return goods info'
      params do
        requires :user_email, type: String, desc: 'User name'
        requires :password, type: String, desc: 'password'
        requires :id, type: Integer, desc: 'order id'
      end
      post :get_goods_info do
        begin
          u = authenticate!(params[:user_email], params[:password])
          goods = Goods.find_by_id(params[:id])
          raise '业务不存在' unless goods.present?

          {
            result: 'success',
            message: '查询商品信息成功',
            name: goods.name,
            price: u.my_price(goods.id),
          }
        rescue => ex
          { result: 'failed', message: ex.message }
        end
      end

      desc 'Return all goods info'
      params do
        requires :user_email, type: String, desc: 'User email'
        requires :password, type: String, desc: 'password'
      end
      post :get_all_goods_info do
        begin
          u = authenticate!(params[:user_email], params[:password])
          all_goods = []
          Goods.all.each do |goods|
            goods_info = {
              id: goods.id,
              name: goods.name,
              price: u.my_price(goods.id)
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
        requires :user_email, type: String, desc: 'User email'
        requires :password, type: String, desc: 'password'
        requires :goods_id, type: Integer, desc: 'goods id'
        requires :count, type: Integer, desc: 'goods count'
        requires :account, type: String, desc: 'account for'
        requires :remark, type: String, desc: 'remark'
      end
      post :insert_order do
        u = authenticate!(params[:user_email], params[:password])
        begin
          count = Integer(params[:count])
          raise '下单数量不能少于1' if count < 1

          goods = Goods.find(params[:goods_id])
          price_current = u.my_price(goods.id)
          total_price =  price_current * count
          raise "本次需要支付#{total_price}元，余额不足，请充值后再下单" if u.balance < total_price

          Order.transaction do
            order = u.orders.create(
                      goods_id: goods.id,
                      remark: params[:remark],
                      account: params[:account],
                      price_current: price_current,
                      count: count,
                      total_price: total_price,
                      level_crrent: u.level,
                      start_num: params[:start_num],
                      aims_num: params[:aims_num],
                      current_num: params[:current_num]
                    )

            u.update_attribute(:balance, u.balance - total_price)

            h_user = u.h_user
            if h_user.present?
              h_price_current = h_user.my_price(goods.id).to_f
              order.update_attributes(h_level_crrent: h_user.level_id, h_price_current: h_price_current)
            end
            u = User.find(u.id)
            {
              result: 'success',
              message: '下单成功',
              id: order.identification_code,
              cost: order.total_price,
              balance: u.balance
            }
          end
        rescue => ex
          { result: 'failed', message: ex.message }
        end
      end

      desc 'set order status'
      params do
        requires :user_email, type: String, desc: 'User name'
        requires :password, type: String, desc: 'password'
        requires :id, type: String, desc: 'Order id'
        requires :states, type: String, desc: 'order states'
      end
      post :set_order_state do
        u = authenticate!(params[:user_email], params[:password])
        raise '权限不够' unless u.admin
        begin
          raise '权限不够' unless u.admin
          order = Order.find_by_identification_code(params[:id].to_s)
          raise '订单信息不存在' unless order.present?
          raise '状态错误' unless Settings.order.status.include?(params[:states])
          Order.transaction do
            order.update_attribute(:status, params[:states])
            u.update_attribute(:balance, user.balance + order.total_price ) if params[:states] == 'Refund'
          end

          { result: 'success', message: '状态更新成功' }
        rescue =>ex
          { result: 'failed', message: ex.message }
        end
      end

      desc 'get orders info'
      params do
        requires :user_email, type: String, desc: 'User name'
        requires :password, type: String, desc: 'password'
      end
      post :get_orders_info_wanted do
        begin
          u = authenticate!(params[:user_email], params[:password])
          raise '权限不够' unless u.admin

          orders = Order.where(nil)
          orders = orders.where(goods_id: params[:goods_id]) if params[:goods_id].present?
          orders = orders.where(status: params[:states]) if params[:states].present?
          orders = orders.where(user_id: params[:user_id]) if params[:user_id].present?

          all_info = []
          orders.each do |order|
            info = {
                    order_id: order.identification_code,
                    status: order.status,
                    order_time: order.created_at,
                    goods_id: order.goods.try(:id),
                    goods_name: order.goods.try(:name),
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
        requires :user_email, type: String, desc: 'User email'
        requires :password, type: String, desc: 'password'
        requires :id, type: String, desc: 'order id'
      end
      post :refund do
        begin
          u = authenticate!(params[:user_email], params[:password])
          raise '权限不够' unless u.admin
          order = Order.find_by_identification_code(params[:id])
          raise '订单不存在' unless order.present?
          raise '已经退款,不可重复退款' if order.status == 'Refund'
          Order.transaction do
            user = order.user
            user.update_attribute(:balance, user.balance + order.total_price)
            order.update_attribute(:status, 'Refund')
            order.update_attribute(:remark, params[:remark]) if params[:remark].present?
          end
          { result: 'success', message: '退款成功' }
        rescue => ex
          { result: 'failed', message: ex.message }
        end
      end

      desc 'set three count'
      params do
        requires :user_email, type: String, desc: 'User email'
        requires :password, type: String, desc: 'password'
        requires :id, type: String, desc: 'order id'
        requires :start_num, type: String, desc: 'start num'
        requires :aims_num, type: String, desc: 'aims num'
        requires :current_num, type: String, desc: 'current num'
      end
      post :set_tree_count do
        begin
          u = authenticate!(params[:user_email], params[:password])
          raise '权限不够' unless u.admin
          order = Order.find_by_identification_code(params[:id])
          raise '订单不存在' unless order.present?
          order.update_attributes(start_num: params[:start_num], aims_num: params[:aims_num], current_num: params[:current_num])
          result = {
            start_num: params[:start_num],
            aims_num: params[:aims_num],
            current_num: params[:current_num]
          }
          { result: 'success', message: '设置成功', data: result }
        rescue => ex
          { result: 'failed', message: ex.message }
        end
      end

      desc 'get expenses info'
      params do
        requires :user_email, type: String, desc: 'User email'
        requires :password, type: String, desc: 'password'
      end
      post :get_expenses_info do
        begin
          u = authenticate!(params[:user_email], params[:password])
          raise '权限不够' unless u.admin
          if params[:user_id].blank?
            user = '所有用户'
            finished_orders = Order.where('status = ?', 'Finished')
            total_spend = finished_orders.map(&:total_price).reduce(:+)
            month_ago_spend = finished_orders.where('created_at BETWEEN ? AND ?', DateTime.now.beginning_of_month, DateTime.now).map(&:total_price).reduce(:+)
            today_spend = finished_orders.where('created_at BETWEEN ? AND ?', DateTime.now.beginning_of_day, DateTime.now).map(&:total_price).reduce(:+)
            # custom_query_spend = finished_orders.where('created_at BETWEEN ? AND ?', params[:start_time], params[:end_time]).map(&:total_price).reduce(:+)
          else
            user = User.find(params[:user_id])
            finished_orders = user.orders.where('status =?', 'Finished')
            total_spend = finished_orders.map(&:total_price).reduce(:+)
            month_ago_spend = finished_orders.where('created_at BETWEEN ? AND ?', DateTime.now.beginning_of_month, DateTime.now).map(&:total_price).reduce(:+)
            today_spend = finished_orders.where('created_at BETWEEN ? AND ?', DateTime.now.beginning_of_day, DateTime.now).map(&:total_price).reduce(:+)
            # custom_query_spend = finished_orders.where('created_at BETWEEN ? AND ?', params[:start_time], params[:end_time]).map(&:total_price).reduce(:+)
            user = user.name
          end
          info =
            {
              user: user,
              total_spend: total_spend,
              month_ago_spend: month_ago_spend,
              today_spend: today_spend
            }
          { result: 'success', message: '查询成功', data: info }
        rescue => ex
          { result: 'success', message: ex.message }
        end
      end

		#if(strtoupper($sign)!=strtoupper(md5($tno.$payno.$money.$md5key)))exit('签名错误');
      #api/member/pay_back
      desc '充值回调'
      params do
        requires :key, type: String, desc: 'api key'
        requires :tno, type: String, desc: '交易号'
        requires :payno, type: Integer, desc: 'user id'
        requires :money, type: String, desc: '付款金额'
        requires :sign, type: String, desc: 'sign'
        requires :typ, type: Integer, desc: 'type'
      end
      get :pay_back do
        begin
          key = 'abc123'
          md5key = 'e99a18'
          error!({result: 'failed', message: 'KEY错误'}, 401) unless key == params[:key]

          puts Digest::MD5.hexdigest(params[:tno].to_s + params[:payno].to_s + params[:money] + md5key)
          if Digest::MD5.hexdigest(params[:tno].to_s + params[:payno].to_s + params[:money] + md5key) != params[:sign]
            error!({result: 'failed', message: '验证失败'}, 401)
          end

          type = case params[:typ].to_i
                 when 1
                   '手工充值'
                 when 2
                   '支付宝充值'
                 when 3
                   '财付通充值'
                 when 4
                   '手Q充值'
                 when 5
                   '微信充值'
                 else
                   '未知'
                 end
          RechargeRecord.transaction do
            params[:money] = params[:money].to_f
            RechargeRecord.create(number: params[:tno], user_id: params[:payno], amount: params[:money], pay_type: type)
            user = User.find(params[:payno])
            user.update_attribute(:balance, user.balance + params[:money])
          end
          result = 1
        rescue
          result = false
        end
        result
      end

    end

  end
end
