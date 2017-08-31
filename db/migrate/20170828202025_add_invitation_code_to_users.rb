class AddInvitationCodeToUsers < ActiveRecord::Migration[5.0]
  def up
    add_column :users, :invitation_code, :string
    add_column :users, :h_invitation_code, :string
    change_column :users, :level_id, :integer, default: 1
  end
end
