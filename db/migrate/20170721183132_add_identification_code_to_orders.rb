class AddIdentificationCodeToOrders < ActiveRecord::Migration[5.0]
  def up
    add_column :orders, :identification_code, :string
  end

  def down
    remove_column :orders, :identification_code, :string
  end
end
