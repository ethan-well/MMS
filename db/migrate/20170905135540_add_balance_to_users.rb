class AddBalanceToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :balance, :float, nill: false, default: 0
  end
end
