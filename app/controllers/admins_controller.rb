class AdminsController < ApplicationController
  before_action :is_admin?
  def index
  end

  def goods
    @goods = Goods.all
  end

  def orders
    @orders = Order.all
  end

  def users
    @users = User.all
  end

  def notices
    @notice = Notice.first
  end

  private
  def is_admin?
    unless current_user.admin
      redirect_to :back, notice: '抱歉，权限不够！'
    end
  end
end
