class SpecialPricesController < ApplicationController
  before_action :is_admin?

  def index
    @goods = Goods.find(params[:goods_id])
    @special_prices = @goods.special_prices
  end

  def create_or_update
    begin
      goods = Goods.find_by_id(params[:goods_id])
      raise '商品不存在' unless goods.present?
      special_price = SpecialPrice.where(user_id: params[:user_id], goods_id: params[:goods_id]).first
      if special_price.present?
        special_price.update_attribute(:price, params[:price])
      else
        SpecialPrice.create(user_id: params[:user_id], goods_id: params[:goods_id], price: params[:price])
      end
      data = { result: 'success', message: '保存成功' }
    rescue => ex
      data = { result: 'failed', message: ex.message }
    end
    render json: data
  end

  def user_special_prices
    @goods = Goods.all
    @user = User.find(params[:user_id])
    @special_prices = @user.special_prices.includes(:goods)
    @goods = @goods.page(params[:page] || 1).per(20)
  end

  def goods_special_prices
    @goods = Goods.find(params[:goods_id])
    @special_prices = @goods.special_prices.includes(:user)
  end

  def destroy
    begin
      special_price = SpecialPrice.find(params[:id])
      special_price.destroy
      flash[:notice] = '删除成功'
    rescue
      flash[:alert] = '删除失败'
    end
    redirect_to :back
  end

  def edit
    @special_price = SpecialPrice.find(params[:id])
  end

  def update
    begin
      @special_price = SpecialPrice.find(params[:id])
      @special_price.update_attributes(params.require(:special_price).permit(:price, :remark, :user_id, :goods_id))
      flash[:notice] = '修改成功'
    rescue
      flash[:alert] = '修改失败'
    end
    redirect_to action: 'user_special_prices', user_id: params[:special_price][:user_id]
  end
end
