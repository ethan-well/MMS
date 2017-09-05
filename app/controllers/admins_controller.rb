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

  def orders
    @orders = Order.where('status = ?', params['status'])
  end

  def users
    @users = User.all
  end

  def notices
    @notice = Notice.first
  end

  def expenses
    # 总消费
    if params[:user] == 'all'
      @user = '所有用户'

    else

    end
  end
end
