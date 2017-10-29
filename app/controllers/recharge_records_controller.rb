class RechargeRecordsController < ApplicationController
  def index
    @recharge_records = current_user.recharge_records
    @recharge_records = @recharge_records.order(created_at: :desc).page(params[:page] || 1).per(20)
  end

  def new

  end
end
