class GoodsController < ApplicationController
  before_action :is_admin?, only: [:create, :update, :destroy]
  def index
  end

  def new
  end

  def create
    #begin
      Goods.create(name: params[:name], price: params[:price], remark: params[:remark])
      notice = '业务添加成功'
    #rescue
      notice = '业务添加失败，稍后重试'
    #end

    redirect_to :back, notice: notice
  end

  def show
    @goods = Goods.find(params[:id])
  end

  def edit
    @goods = Goods.find(params[:id])
  end

  def update
    #begin
      goods = Goods.find(params[:id])
      goods.update_attributes(params.require('goods').permit(:name, :price, :remark))
      notice = '修改成功'
    #rescue
      notice = '修改失败'
    #end

    redirect_to goods_admins_path, notice: notice
  end

  def destroy
    begin
      good = Goods.find(params[:id])
      good.destroy
      notice = '删除成功'
    rescue
      notice = '删除失败'
    end

    redirect_to goods_admins_path, notice: notice
  end

  def get_price
    goods = Goods.find(params['id'])
    level = current_user.level_id
    special_price = current_user.current_goods_special_prices(goods.id)
    price = goods.get_current_price(level)
    return render json: { price: special_price || price }
  end
end
