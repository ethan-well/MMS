class SpecialPricesController < ApplicationController
  before_action :is_admin?

  def index
    @goods = Goods.find(params[:goods_id])
    @special_prices = @goods.special_prices
  end

  def create
    begin
      SpecialPrice.create(params.require(:special_price).permit(:price, :remark, :user_id, :goods_id))
      notice = '创建成功'
    rescue
      notice = '创建失败'
    end
    redirect_to :back, notice: notice
  end

  def user_special_prices
    @user = User.find(params[:user_id])
    @special_prices = @user.special_prices.includes(:goods)
  end

  def goods_special_prices
    @goods = Goods.find(params[:goods_id])
    @special_prices = @goods.special_prices.includes(:user)
  end

  def destroy
    begin
      special_price = SpecialPrice.find(params[:id])
      special_price.destroy
      notice = '删除成功'
    rescue
      notice = '删除失败'
    end
    redirect_to :back, notice: notice
  end

  def edit
    @special_price = SpecialPrice.find(params[:id])
  end

  def update
    begin
      @special_price = SpecialPrice.find(params[:id])
      @special_price.update_attributes(params.require(:special_price).permit(:price, :remark, :user_id, :goods_id))
      notice = '修改成功'
    rescue
      notice = '修改失败'
    end
    redirect_to action: 'user_special_prices', user_id: params[:special_price][:user_id]
  end
end
