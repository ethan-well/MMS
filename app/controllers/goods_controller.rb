class GoodsController < ApplicationController
  def index
  end

  def new
  end

  def create
  end

  def show
  end

  def update
  end

  def destroy
  end

  def get_price
    goods = Goods.find(params['id'])
    level = current_user.level_id
    price = goods.get_current_price(level)

    return render json: { price: price }
  end
end
