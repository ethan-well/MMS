class HSetPricesController < ApplicationController
  def index
    @goods = Goods.all
    @user = current_user.low_level_users.find_by_id(params[:user_id])
    return redirect_to :back, alert: '用户不存在' unless @user.present?
    @goods = @goods.page(params[:page] || 0).per(10)
  end

  def create_or_update
    begin
      @user = current_user.low_level_users.find_by_id(params[:user_id])
      raise '用户不存在' unless @user.present?

      goods = Goods.find_by_id(params[:goods_id])
      raise '业务类型不存在' unless goods

      price = Float(params[:special_price])
      current_level_price =  goods.get_current_price(@user.level_id)
      raise "价格不能低于#{current_level_price}" if price < current_level_price
      raise "价格不能高于系统价格三倍" if price > goods.get_current_price(@user.level_id) * 3

      if HSetPrice.exists?(user_id: @user.id, goods_id: goods.id)
        h_set_price = HSetPrice.where(user_id: @user.id, goods_id: goods.id).first
        h_set_price.update_attribute(:price, price)
      else
        HSetPrice.create(user_id: @user.id, goods_id: goods.id, price: price)
      end
      data = { result: 'success', message: '添加成功' }
    rescue => ex
      data = { result: 'failed', message: ex.message }
    end

    return render json: data
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
