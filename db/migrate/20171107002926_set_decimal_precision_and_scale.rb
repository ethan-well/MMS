class SetDecimalPrecisionAndScale < ActiveRecord::Migration[5.0]
  def change
    change_column :users, :balance, :decimal,  precision: 20,  scale: 10
  end
end
