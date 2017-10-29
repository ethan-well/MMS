class AddGoodsTypeIdToGoods < ActiveRecord::Migration[5.0]
  def change
    add_column :goods, :goods_type_id, :integer
  end
end
