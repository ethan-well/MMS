module GoodsHelper
  def price_light?(price, good_id)
    price == current_user.current_goods_special_prices(@goods.id) ? 'bg-green' : ''
  end
end
