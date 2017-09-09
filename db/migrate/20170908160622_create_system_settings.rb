class CreateSystemSettings < ActiveRecord::Migration[5.0]
  def change
    create_table :system_settings do |t|
      t.boolean :can_sigin_up, default: true
      t.boolean :can_recharge, default: true
      t.timestamp
    end
  end
end
