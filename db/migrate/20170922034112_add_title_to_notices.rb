class AddTitleToNotices < ActiveRecord::Migration[5.0]
  def change
    add_column :notices, :title, :string
  end
end
