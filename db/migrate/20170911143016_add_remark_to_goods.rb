class AddRemarkToGoods < ActiveRecord::Migration[5.0]
  def change
    add_column :goods, :remark, :string
  end
end
