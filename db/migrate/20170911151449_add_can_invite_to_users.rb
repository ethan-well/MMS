class AddCanInviteToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :can_invite, :boolean, default: true
  end
end
