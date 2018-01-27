class AddIndexToOrder < ActiveRecord::Migration[5.0]
  def change
    add_index :orders, :id
    add_index :orders, :status
    add_index :orders, :goods_id
    add_index :orders, :user_id
    add_index :orders, :identification_code
  end
end
