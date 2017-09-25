class AddPayTypeToRechargeRecords < ActiveRecord::Migration[5.0]
  def change
    add_column :recharge_records, :number, :string
    add_column :recharge_records, :pay_type, :string
    add_column :recharge_records, :created_at, :datetime, null: false
    add_column :recharge_records, :updated_at, :datetime, null: false
  end
end
