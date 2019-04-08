class ChangeWatchesName < ActiveRecord::Migration[5.1]
  def change
    rename_table :watches, :issues_users
  end
end
