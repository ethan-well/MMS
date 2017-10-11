class DeductPercentagesController < ApplicationController
  def index
    @deduct_percentages = DeductPercentage.where(low_user_id: params[:user_id])
  end
end
