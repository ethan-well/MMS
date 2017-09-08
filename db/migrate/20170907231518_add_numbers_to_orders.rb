class AddNumbersToOrders < ActiveRecord::Migration[5.0]
  def change
    add_column :orders, :start_num, :integer
    add_column :orders, :aims_num, :integer
    add_column :orders, :current_num, :integer
  end
end
