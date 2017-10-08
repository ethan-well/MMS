class AddNeedInvitationCodeToSystemSettings < ActiveRecord::Migration[5.0]
  def change
    add_column :system_settings, :need_invitation_code, :boolean, default: false
  end
end
