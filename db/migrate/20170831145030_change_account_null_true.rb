class ChangeAccountNullTrue < ActiveRecord::Migration[5.0]
  def change
    #remove_column :orders, :account
    add_column :orders, :account, :string, null: true
  end
end
