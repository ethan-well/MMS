class RechargeRecordsController < ApplicationController
  def index
    @recharge_records = RechargeRecord.all
  end
end
