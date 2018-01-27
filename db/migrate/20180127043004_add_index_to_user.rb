class AddIndexToUser < ActiveRecord::Migration[5.0]
  def change
    add_index :users, :id
    add_index :users, :name
    add_index :users, :level_id
    add_index :users, :invitation_code
    # add_index :users, :h_invitation_code
  end
end
