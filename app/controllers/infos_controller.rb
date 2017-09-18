class InfosController < ApplicationController
  def index
    @goods = Goods.all
    @total_spend = current_user.total_spend
    @orders_count = current_user.orders.count
    @notices = Notice.all
  end
end
