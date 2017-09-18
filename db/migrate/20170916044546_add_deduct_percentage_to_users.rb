class AddDeductPercentageToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :deduct_percentage, :float
  end
end
