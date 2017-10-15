class AddMd5PasswordToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :md5_password, :string
  end
end
