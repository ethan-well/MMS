class CreateRechargeRecords < ActiveRecord::Migration[5.0]
  def change
    create_table :recharge_records do |t|
      t.float :amount, default: 0.0
      t.integer :user_id
      t.timestamp
    end
  end
end
