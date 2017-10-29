class CreateGoodsType < ActiveRecord::Migration[5.0]
  def change
    create_table :goods_types do |t|
      t.string :name
      t.integer :serial
      t.string :remark
      t.timestamps
    end
  end
end
