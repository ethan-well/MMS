class OrdersController < ApplicationController
  before_action :current_order, only: [:cancel, :finished, :edit]
  before_action :validate_user, only: [:cancel, :finished]
  before_action :validate_can_edit, only: [:edit]
  before_action :is_admin?, only: [:admin_change_status]

  def index
    @orders = current_user.orders.includes(:goods)
    search_order
    @orders = @orders.order(created_at: :desc).page(params[:page] || 1).per(5)
  end

  def purchase_history
    if params[:id].blank?
      @goods = '所有商品'
      @finished_orders = current_user.orders.where('status = ?', 'Finished')
      @total_spend = @finished_orders.map(&:total_price).reduce(:+)
      @month_ago_spend = @finished_orders.where('created_at BETWEEN ? AND ?', DateTime.new.beginning_of_month, DateTime.now).map(&:total_price).reduce(:+)
      @today_spend = @finished_orders.where('created_at BETWEEN ? AND ?', DateTime.new.beginning_of_day, DateTime.now).map(&:total_price).reduce(:+)
      @custom_query_spend = @finished_orders.where('created_at BETWEEN ? AND ?', params[:start_time], params[:end_time]).map(&:total_price).reduce(:+)
    else
      @goods = Goods.find(params[:id])
      @finished_orders = current_user.orders.where('goods_id = ?', params[:id]).where('status =?', 'Finished')
      @total_spend = @finished_orders.map(&:total_price).reduce(:+)
      @month_ago_spend = @finished_orders.where('created_at BETWEEN ? AND ?', DateTime.new.beginning_of_month, DateTime.now).map(&:total_price).reduce(:+)
      @today_spend = @finished_orders.where('created_at BETWEEN ? AND ?', DateTime.new.beginning_of_day, DateTime.now).map(&:total_price).reduce(:+)
      @custom_query_spend = @finished_orders.where('created_at BETWEEN ? AND ?', params[:start_time], params[:end_time]).map(&:total_price).reduce(:+)
      @goods = @goods.name
    end
  end

  def new
    @order = Order.new
    puts params[:goods_id]
    @goods = Goods.find(params[:goods_id])
  end

  def edit
    @order = Order.find(params[:id])
  end

  def create
    begin
      goods_id = params['order']['goods_id']
      if params['order']['remark'].present?
        remark = params['order']['remark']
        order_info = remark.gsub(' ', '').split(/[\r\n]+/)
        count = 0
        order_info.each do |info|
          info = info.split('----')
          count += Integer(info[1])
        end
      else
        count = params['order']['count']
      end

      goods = Goods.find(goods_id)
      if goods.present?
        price_current = current_user.my_price(goods.id)
        total_price = price_current.to_f * count.to_i

        if current_user.balance < total_price
          render redirect_to :back, notice: "余额不足，下单失败。本次需支付#{total_price}元，您账户余额#{current_user.balance}元。请充值后再下单"
        end
        Order.transaction do
          current_user.update_attribute(:balance, current_user.balance - total_price)

          order =  current_user.orders.create(params.require(:order).permit(:goods_id, :remark, :account))
          order.update_attributes(price_current: price_current, count: count, total_price: total_price)
        end
      else
        notice = '业务类型不存在，请核对后重新下单'
      end
    rescue => e
      notice = e.message
    end
    redirect_to :back, notice: notice
  end

  def update
    begin
      @order = Order.find(params[:id])
      goods = Goods.find(params[:order][:goods_id])
      count = params[:order][:count]
      if @order.is_paied?
        attritutes = params.require(:order).permit(:remark)
        @order.update_attributes(attritutes)
      else
        remark = params[:order][:remark]
        price_current = goods.get_current_price(current_user.level_id)
        total_price = price_current.to_i * count.to_i

        @order.update_attributes(goods_id: goods.id, price_current: price_current, count: count, total_price: total_price, remark: remark)
      end
      notice = '订单修改完成'
    rescue
      notice = '订单修改失败'
    end

    redirect_to action: 'index', notice: notice
  end

  def cancel
    # begin
      if @order.can_cancel?
        @order.update_attribute(:status, 'Canceled')
        notice = '订单已取消'
      else
        notice = '订单取消失败, 当前订单不可取消'
      end
    # rescue
      notice = '订单取消失败，请刷新页面后重试'
    # end

    redirect_to :back, notice: notice
  end

  def finished
    begin
      if @order.can_make_finished?
        @order.update_attribute(:status, 'Finished')
        notice = '订单已完成'
      else
        notice = '当前订单状态不能变更为以完成'
      end
    rescue
      notice = '变更状态失败，请刷新页面后重试'
    end

    redirect_to :back, notice: notice
  end

  def admin_change_status
    @order = Order.find(params[:id])
    @order.update_attribute(:status, params[:status])

    redirect_to :back, notice: '状态变更成功'
  end

  private
  def current_order
    @order = Order.find(params['id'])
  end

  def validate_user
    return redirect_to :back, notice: '权限错误！' if @order.user_id != current_user.id
  end

  def validate_can_edit
    return redirect_to :back, notice: '当前订单不可以修改！' if !@order.can_edit?
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
end
