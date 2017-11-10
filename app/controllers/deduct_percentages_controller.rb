class DeductPercentagesController < ApplicationController
  def index
    @deduct_percentages = DeductPercentage.where(user_id: current_user.id, low_user_id: params[:user_id])
  end
end
