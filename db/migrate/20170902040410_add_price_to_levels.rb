class AddPriceToLevels < ActiveRecord::Migration[5.0]
  def change
    add_column :levels, :price, :float
  end
end
