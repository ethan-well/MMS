class OrdersController < ApplicationController
  before_action :current_order, only: [:edit, :update]
  before_action :is_admin?, only: [:admin_change_status, :update, :edit, :manage_on_sale]

  def index
    @orders = current_user.orders.includes(:goods)
    search_order
    @orders = @orders.order(created_at: :desc).page(params[:page] || 1).per(20)
  end

  def purchase_history
    if params[:id].blank?
      @goods = '所有商品'
      @finished_orders = current_user.orders.where('status = ?', 'Finished')
      @total_spend = @finished_orders.sum(:total_price)
      @month_ago_spend = @finished_orders.where('created_at BETWEEN ? AND ?', DateTime.now.beginning_of_month, DateTime.now).sum(:total_price)
      @today_spend = @finished_orders.where('created_at BETWEEN ? AND ?', DateTime.now.beginning_of_day, DateTime.now).sum(:total_price)
      @custom_query_spend = @finished_orders.where('created_at BETWEEN ? AND ?', params[:start_time], params[:end_time]).sum(:total_price)
    else
      @goods = Goods.find(params[:id])
      @finished_orders = current_user.orders.where('goods_id = ?', params[:id]).where('status =?', 'Finished')
      @total_spend = @finished_orders.sum(:total_price)
      @month_ago_spend = @finished_orders.where('created_at BETWEEN ? AND ?', DateTime.now.beginning_of_month, DateTime.now).sum(:total_price)
      @today_spend = @finished_orders.where('created_at BETWEEN ? AND ?', DateTime.now.beginning_of_day, DateTime.now).sum(:total_price)
      @custom_query_spend = @finished_orders.where('created_at BETWEEN ? AND ?', params[:start_time], params[:end_time]).sum(:total_price)
      @goods = @goods.name
    end
  end

  def new
    @order = Order.new
    @goods = Goods.find(params[:goods_id])
    is_on_sale?(@goods.on_sale)
    @orders = current_user.orders.where(goods_id: @goods.id)
    @orders = @orders.order(created_at: :desc).page(params[:page] || 1).per(10)
  end

  def edit
    @order = Order.find(params[:id])
  end

  def create
    begin
      goods_id = params['order']['goods_id']
      goods = Goods.find_by_id(goods_id)
      return redirect_to :back, notice: '业务不存在，请核对后重新下单' unless goods.present?
      is_on_sale?(goods.on_sale)
      price_current = current_user.my_price(goods.id).to_f

      # 批量订单
      if params[:multiple_order]
        begin
          infos = params['multiple_order']
          order_info = infos.gsub(' ', '').split(/[\r\n]+/)
          total_count = 0
          Order.transaction do
            user = User.lock.find(current_user.id)
            h_user = user.h_user
            order_info.each do |info|
              info = info.split('----')
              count = Integer(info[1])
              raise '下单数量至少为1' if count < 1
              total_count += count.to_i
              order = user.orders.create( goods_id: goods_id, price_current: price_current,
                  count: count, total_price: price_current * count, account: info[0],
                  level_crrent: user.level_id )

              if h_user.present?
                h_price_current = h_user.my_price(goods.id).to_f
                order.update_attributes(h_level_crrent: h_user.level_id, h_price_current: h_price_current)
              end
            end
            multiple_order_total_price = total_count * price_current.to_f
            raise '余额不足，请充值后下单' if user.balance < multiple_order_total_price
            user.update_attribute(:balance, user.balance - multiple_order_total_price )
          end
          message = '下单成功'
        rescue => ex
          message = ex.message
        end

        flash[:message] = message
        return redirect_to :back
      end

      count = Integer(params['order']['count'])
      raise '下单数量至少为1' if count < 1
      total_price = price_current * count

      # 普通订单
      Order.transaction do
        user = User.lock.find(current_user.id)
        raise "余额不足,请充值后再下单" if user.balance < total_price
        user.update_attribute(:balance, user.balance - total_price)

        order =  user.orders.create(params.require(:order).permit(:goods_id, :remark, :account))
        order.update_attributes(price_current: price_current, count: count, total_price: total_price, level_crrent: user.level)
        h_user = user.h_user
        if h_user.present?
          h_price_current = h_user.my_price(goods.id).to_f
          order.update_attributes(h_level_crrent: h_user.level_id, h_price_current: h_price_current)
        end
      end
      message = '下单成功'
    rescue => ex
      message = ex.message
    end
    flash[:message] = message
    return redirect_to :back
  end

  def update
    begin
      goods = Goods.find(params[:order][:goods_id])
      count = params[:order][:count]
      if @order.is_paied?
        attritutes = params.require(:order).permit(:remark)
        @order.update_attributes(attritutes)
      else
        remark = params[:order][:remark]
        price_current = goods.get_current_price(current_user.level_id)
        total_price = price_current.to_f * count.to_i

        @order.update_attributes(goods_id: goods.id, price_current: price_current, count: count, total_price: total_price, remark: remark)
      end
      flash[:notice] = '订单修改完成'
    rescue
      flash[:alert] = '订单修改失败'
    end

    redirect_to action: 'index'
  end

  def admin_change_status
    @order = Order.find(params[:id])
    return redirect_to :back, notice: '订单状态已经退款，状态不能改变' if @order.status == 'Refund'
    Order.transaction do
      user = User.lock.find(@order.user_id)
      @order.update_attribute(:status, params[:status])
      user.update_attribute(:balance, user.balance + @order.total_price ) if params[:status] == 'Refund'
    end

    redirect_to :back
  end

  def manage_on_sale
    goods = Goods.find(params[:id])
    goods.update_attribute(:on_sale, params[:on_sale])
  end

  private
  def current_order
    @order = Order.find(params['id'])
  end

  def search_order
    filter_params = params.permit(['status', 'goods_id', 'account', 'remark'])
    filter_params.each do |filter_param, value|
      if value.present?
        puts filter_param
        if ['status', 'goods_id'].include? filter_param
          @orders = @orders.where("#{filter_param} = ?", value)
        else ['account', 'remark'].include? filter_param
          @orders = @orders.where("#{filter_param} LIKE ?", "%#{value}%")
        end
      end
    end
  end

  def is_on_sale?(on_sale)
    redirect_to :orders, alert: '商品已经下架' unless on_sale
  end
end
