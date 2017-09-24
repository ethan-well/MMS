class AddLevelCurrentToOrders < ActiveRecord::Migration[5.0]
  def change
    add_column :orders, :level_crrent, :integer
  end
end
