class OrdersController < ApplicationController
 def index
   @orders = current_user.orders
   @orders = @orders.paginate(:page => params[:page] || 1)
 end

 def new
   @order = Order.new
 end

 def create
  current_user.orders.create(params.require(:order).permit(:goods_id, :price_current, :count, :account, :secreate_string, :secreate_string))
  redirect_to :back
 end

end
