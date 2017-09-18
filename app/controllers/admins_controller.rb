class AdminsController < ApplicationController
  before_action :is_admin?
  def index
  end

  def goods
    @goods = Goods.all
  end

  def create_goods
    begin
      Goods.create(params.require(:goods).permit(:name, :price))
      notice = '业务添加成功'
    rescue
      notice = '业务添加失败，稍后重试'
    end

    redirect_to :back, notice: notice
  end

  def edit_user
    @user = User.find(params[:user_id])
    respond_to do |format|
      format.js
    end
  end

  def update_user
    begin
      user = User.find(params[:id])
      raise '等级不合法'  unless Level.find(params[:level_id]).present?
      user.update_attributes(level_id: params[:level_id], balance: params[:balance], can_invite: params[:can_invite], active: params[:active])
      nitice = '用户信息更改成功'
    rescue => ex
      notice = ex.message
    end
    return redirect_to :back, notice: notice
  end

  def orders
    @orders = Order.where('status = ?', params['status']).order('created_at desc')
  end

  def users
    @users = User.all
  end

  def notices
    @notices = Notice.all
  end

  def expenses
    # 总消费
    if params[:id].blank?
      @user = '所有用户'
      @finished_orders = Order.where('status = ?', 'Finished')
      @total_spend = @finished_orders.map(&:total_price).reduce(:+)
      @month_ago_spend = @finished_orders.where('created_at BETWEEN ? AND ?', DateTime.new.beginning_of_month, DateTime.now).map(&:total_price).reduce(:+)
      @today_spend = @finished_orders.where('created_at BETWEEN ? AND ?', DateTime.new.beginning_of_day, DateTime.now).map(&:total_price).reduce(:+)
      @custom_query_spend = @finished_orders.where('created_at BETWEEN ? AND ?', params[:start_time], params[:end_time]).map(&:total_price).reduce(:+)
    else
      @user = User.find(params[:id])
      @finished_orders = @user.orders.where('status =?', 'Finished')
      @total_spend = @finished_orders.map(&:total_price).reduce(:+)
      @month_ago_spend = @finished_orders.where('created_at BETWEEN ? AND ?', DateTime.new.beginning_of_month, DateTime.now).map(&:total_price).reduce(:+)
      @today_spend = @finished_orders.where('created_at BETWEEN ? AND ?', DateTime.new.beginning_of_day, DateTime.now).map(&:total_price).reduce(:+)
      @custom_query_spend = @finished_orders.where('created_at BETWEEN ? AND ?', params[:start_time], params[:end_time]).map(&:total_price).reduce(:+)
      @user = @user.name
    end
  end
end
