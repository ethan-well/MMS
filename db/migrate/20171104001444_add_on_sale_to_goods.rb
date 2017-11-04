class AddOnSaleToGoods < ActiveRecord::Migration[5.0]
  def change
    add_column :goods, :on_sale, :boolean, default: true
  end
end
