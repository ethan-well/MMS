class ChangeFloatToDecimal < ActiveRecord::Migration[5.0]
  def change
    change_column :users, :balance, :decimal
  end
end
