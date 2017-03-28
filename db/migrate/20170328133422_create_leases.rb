class CreateLeases < ActiveRecord::Migration[5.0]
  def change
    create_table :leases do |t|
      t.belongs_to :user
      t.belongs_to :card
      t.boolean :active
      t.timestamps
    end
  end
end
