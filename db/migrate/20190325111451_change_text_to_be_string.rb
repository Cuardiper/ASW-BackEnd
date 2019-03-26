class ChangeTextToBeString < ActiveRecord::Migration[5.1]
  def change
    change_column :issues, :title, :string
    change_column :issues, :type, :string
    change_column :issues, :priority, :string
    change_column :issues, :status, :string
  end
end
