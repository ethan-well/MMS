class AddIsAlertToNotices < ActiveRecord::Migration[5.0]
  def change
    add_column :notices, :is_alert, :boolean, default: true
  end
end
