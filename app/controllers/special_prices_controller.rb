class SpecialPricesController < ApplicationController
  def index
    @goods = Goods.find(params[:goods_id])
    @special_prices = @goods.special_prices
  end
end
