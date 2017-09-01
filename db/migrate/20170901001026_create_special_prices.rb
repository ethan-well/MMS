class CreateSpecialPrices < ActiveRecord::Migration[5.0]
  def change
    create_table :special_prices do |t|
      t.float :price
      t.string :remark
      t.integer :user_id
      t.integer :goods_id
      t.timestamps
    end
  end
end
