class DeductPercentagesController < ApplicationController
  def index
    @deduct_percentages = DeductPercentage.find_by_order_user_id(params[:user_id]) || []
  end
end
