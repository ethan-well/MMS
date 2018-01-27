class AddIndexToGoods < ActiveRecord::Migration[5.0]
  def change
    add_index :goods, :id
    add_index :goods, :name
    add_index :goods, :goods_type_id
  end
end
