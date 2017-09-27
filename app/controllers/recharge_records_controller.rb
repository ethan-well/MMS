class RechargeRecordsController < ApplicationController
  def index
    @recharge_records = current_user.recharge_records
  end
end
