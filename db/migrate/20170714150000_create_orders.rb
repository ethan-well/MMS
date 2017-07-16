class CreateOrders < ActiveRecord::Migration[5.0]
  def change
    create_table :orders do |t|
      t.decimal :price_current, null: false
      t.integer :count, null: false, default: 0
      t.decimal :total_price, null: false, default: 0
      t.string  :status, null: false, :default => 'Waiting'
      t.string :account, null: false
      t.string :secreate_string
      t.integer :goods_id
      t.integer :user_id
      t.timestamps
    end
  end
end
