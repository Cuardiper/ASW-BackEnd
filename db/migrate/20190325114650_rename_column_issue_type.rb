class RenameColumnIssueType < ActiveRecord::Migration[5.1]
  def change
    rename_column :issues, :issue_type, :type_issue
  end
end
