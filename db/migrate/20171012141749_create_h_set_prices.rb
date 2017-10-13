class CreateHSetPrices < ActiveRecord::Migration[5.0]
  def change
    create_table :h_set_prices do |t|
      t.float :price, default: 0.0
      t.integer :user_id
      t.integer :goods_id
      t.timestamps
    end
  end
end
