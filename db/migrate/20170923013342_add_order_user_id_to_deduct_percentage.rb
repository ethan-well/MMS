class AddOrderUserIdToDeductPercentage < ActiveRecord::Migration[5.0]
  def change
    add_column :deduct_percentages, :order_user_id, :integer
  end
end
