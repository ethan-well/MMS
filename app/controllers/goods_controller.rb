class GoodsController < ApplicationController
  before_action :is_admin?, only: [:create, :update, :destroy]
  def index
  end

  def new
  end

  def create
    begin
      raise '价格不能为空' if params[:price].nil?
      price_arr = params[:price].split(' ')
      raise '价格格式错误' if  price_arr.length < 4
      raise '类型不能为空' if params[:type_id].nil?
      raise '类型不存在' unless GoodsType.find_by_id(params[:type_id])
      price_arr.each do |price|
        Float(price)
      end
      Goods.create(goods_type_id: params[:type_id],name: params[:name], price: params[:price], remark: params[:remark])
      flash[:notice] = '业务添加成功'
    rescue => ex
      flash[:alert] = ex.message
    end

    redirect_to :back
  end

  def show
    @goods = Goods.find(params[:id])
  end

  def edit
    @goods = Goods.find(params[:id])
  end

  def update
    begin
      goods = Goods.find(params[:id])
      goods.update_attributes(params.require('goods').permit(:name, :price, :remark, :goods_type_id))
      flash[:notice] = '修改成功'
    rescue
      flash[:alert] = '修改失败'
    end

    redirect_to goods_admins_path
  end

  def destroy
    begin
      good = Goods.find(params[:id])
      good.destroy
      flash[:notice] = '删除成功'
    rescue
      flash[:alert] = '删除失败'
    end

    redirect_to goods_admins_path
  end

  def get_price
    goods = Goods.find(params['id'])
    level = current_user.level_id
    special_price = current_user.current_goods_special_prices(goods.id)
    price = goods.get_current_price(level)
    return render json: { price: special_price || price }
  end
end
