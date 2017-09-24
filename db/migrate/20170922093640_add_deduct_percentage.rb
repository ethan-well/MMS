class AddDeductPercentage < ActiveRecord::Migration[5.0]
  def change
    create_table :deduct_percentages do |t|
      t.integer :user_id
      t.integer :order_id
      t.float :deduct_percentages
      t.timestamp
    end
  end
end
