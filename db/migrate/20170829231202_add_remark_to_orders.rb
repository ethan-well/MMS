class AddRemarkToOrders < ActiveRecord::Migration[5.0]
  def up
    add_column :orders, :remark, :text
  end

  def down
    remove_column :orders, :remark
  end
end
