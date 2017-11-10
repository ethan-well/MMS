class AdminsController < ApplicationController
  before_action :is_admin?
  def index
  end

  def goods
    @goods = Goods.all
    if params[:goods_id].present?
       @goods =  @goods.where(id: params[:goods_id])
     elsif params[:goods_type_id].present?
       @goods =  @goods.where(goods_type_id: params[:goods_type_id])
     end
    @goods = @goods.order(created_at: :desc).page(params[:page] || 1).per(20)
  end

  def types
    @types = GoodsType.all
    @types = @types.order(created_at: :desc).page(params[:page] || 1).per(20)
  end

  def create_goods
    begin
      Goods.create(params.require(:goods).permit(:name, :price))
      flash[:notice] = '业务添加成功'
    rescue
      flash[:alert] = '业务添加失败，稍后重试'
    end

    redirect_to :back
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
      raise '设置的等级不能低于用户当前等级' unless params[:level_id].to_i < user.level_id
      balance = Float(params[:balance])
      user.update_attributes(level_id: params[:level_id])
      if balance > 0
        User.transaction do
          recharge_records =  RechargeRecord.create(user_id: user.id, amount: balance, pay_type: '管理员加款')
          user.update_attribute(:balance, user.balance + balance)
        end
      end
      flash[:nitice] = '用户信息更改成功'
    rescue => ex
      flash[:alert] = ex.message
    end
    return redirect_to :back
  end

  def orders
    @orders = Order.where('status = ?', params['status']).order('created_at desc')
    search_orders
    @orders = @orders.order(created_at: :desc).page(params[:page] || 1).per(20)
  end

  def users
    @users =
      if params[:user_id].present?
        User.where(id: params[:user_id])
      else
        User.all
      end
    @users = @users.order(created_at: :desc).page(params[:page] || 1).per(20)
  end

  def can_log_in_or_invite
    u = User.find_by_id(params[:id])
    u.update_attributes(params[:change_info].to_hash)
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
      @month_ago_spend = @finished_orders.where('created_at BETWEEN ? AND ?', DateTime.now.beginning_of_month, DateTime.now).map(&:total_price).reduce(:+)
      @today_spend = @finished_orders.where('created_at BETWEEN ? AND ?', DateTime.now.beginning_of_day, DateTime.now).map(&:total_price).reduce(:+)
      @custom_query_spend = @finished_orders.where('created_at BETWEEN ? AND ?', params[:start_time], params[:end_time]).map(&:total_price).reduce(:+)
    else
      @user = User.find(params[:id])
      @finished_orders = @user.orders.where('status =?', 'Finished')
      @total_spend = @finished_orders.map(&:total_price).reduce(:+)
      @month_ago_spend = @finished_orders.where('created_at BETWEEN ? AND ?', DateTime.now.beginning_of_month, DateTime.now).map(&:total_price).reduce(:+)
      @today_spend = @finished_orders.where('created_at BETWEEN ? AND ?', DateTime.now.beginning_of_day, DateTime.now).map(&:total_price).reduce(:+)
      @custom_query_spend = @finished_orders.where('created_at BETWEEN ? AND ?', params[:start_time], params[:end_time]).map(&:total_price).reduce(:+)
      @user = @user.name
    end
  end

  def search_orders
    filter_params = params.permit(['user_id', 'goods_id', 'account', 'remark'])
    filter_params.each do |filter_param, value|
      if value.present?
        if ['user_id', 'goods_id'].include? filter_param
          @orders = @orders.where("#{filter_param} = ?", value)
        else ['account', 'remark'].include? filter_param
          @orders = @orders.where("#{filter_param} LIKE ?", "%#{value}%")
        end
      end
    end
  end

  def edit_user_password
    @user = User.find(params[:user_id])
    respond_to do |format|
      format.js
    end
  end

  def update_user_password
    begin
      user = User.find_by_id(params[:id])
      raise '用户不存在' unless user.present?
      user.password = params[:password]
      user.password_confirmation = params[:password_confirmation]
      user.md5_password = Digest::MD5.hexdigest(current_user.email + 'WoNiMaDeYa' + Time.now.to_s)
      user.save!
      flash[:notice] = '密码更改成功！'
    rescue => ex
      flash[:alert] = ex.message
    end
    redirect_to :back
  end
end
