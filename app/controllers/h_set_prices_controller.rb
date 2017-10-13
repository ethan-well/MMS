class HSetPricesController < ApplicationController
  def index
    @user = current_user.low_level_users.find_by_id(params[:user_id])
    return redirect_to :back, alert: '用户不存在' unless @user.present?

    @h_set_prices = HSetPrice.where(user_id: params[:user_id])
  end

  def create
    begin
      @user = current_user.low_level_users.find_by_id(params[:h_set_price][:user_id])
      raise '用户不存在' unless @user.present?

      goods = Goods.find_by_id(params[:h_set_price][:goods_id])
      raise '业务类型不存在' unless goods

      price = Float(params[:h_set_price][:price])
      current_level_price =  goods.get_current_price(@user.level_id)
      raise "价格不能低于#{current_level_price}" if price < current_level_price

      raise '该业务已经设置特价' if HSetPrice.exists?(user_id: @user.id, goods_id: goods.id)

      HSetPrice.create(params.require(:h_set_price).permit(:user_id, :goods_id, :price))
    rescue => ex
      return redirect_to :back, alert: ex.message
    end

    return redirect_to :back, notice: '特价添加成功'
  end

  def edit
    @h_set_price = HSetPrice.find(params[:id])

    respond_to do |format|
      format.js
    end
  end

  def update
    @h_set_price = HSetPrice.find_by_id(params[:h_set_price][:id])
    goods = @h_set_price.goods
    user = @h_set_price.user
    return redirect_to :back, alert: '无权操作' unless current_user.invitation_code ==  user.h_invitation_code

    price = Float(params[:h_set_price][:price])
    current_level_price =  goods.get_current_price(user.level_id)
    if price < current_level_price
      return redirect_to :back, alert: "价格不能低于#{current_level_price}"
    end
    @h_set_price.update_attribute(:price, price)

    return redirect_to :back, notice: '更新成功'
  end

  def destroy
    @h_set_price = HSetPrice.find_by_id(params[:id])
    user = @h_set_price.user
    return redirect_to :back, alert: '无权删除' unless current_user.invitation_code ==  user.h_invitation_code

    @h_set_price.destroy
    return redirect_to :back, notice: '删除成功'
  end
end
