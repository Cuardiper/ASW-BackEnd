class RenameColumnType < ActiveRecord::Migration[5.1]
  def change
    rename_column :issues, :type, :issue_type
  end
end
