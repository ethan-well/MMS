class CreateLevel < ActiveRecord::Migration[5.0]
  def change
    create_table :levels do |t|
      t.integer :number
      t.string :descripte
      t.timestamps
    end
  end
end
