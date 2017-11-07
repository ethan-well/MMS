class ChangeAllFloatToDecimal < ActiveRecord::Migration[5.0]
  def change
    change_column :deduct_percentages, :deduct_percentages, :decimal,  precision: 30,  scale: 10
    change_column :h_set_prices, :price, :decimal, precision: 30, scale: 10
    change_column :levels, :price, :decimal, precision: 30, scale: 10
    change_column :orders, :price_current, :decimal, precision: 30, scale: 10
    change_column :orders, :total_price, :decimal, precision: 30, scale: 10
    change_column :orders, :h_price_current, :decimal, precision: 30, scale: 10
    change_column :recharge_records, :amount, :decimal, precision: 30, scale: 10
    change_column :special_prices, :price, :decimal, precision: 30, scale: 10
    change_column :users, :deduct_percentage, :decimal, precision: 30, scale: 10
  end
end
