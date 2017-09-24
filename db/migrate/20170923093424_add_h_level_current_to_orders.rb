class AddHLevelCurrentToOrders < ActiveRecord::Migration[5.0]
  def change
    add_column :orders, :h_level_crrent, :integer
    add_column :orders, :h_price_current, :float

    add_column :deduct_percentages, :low_user_id, :integer
  end
end
