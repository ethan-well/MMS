class SorceryCore < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.string :email,            :null => false
      t.string :crypted_password
      t.string :salt
      t.string :phone_number
      t.string :city

      t.timestamps
    end

    add_index :users, :email, unique: true
  end
end
