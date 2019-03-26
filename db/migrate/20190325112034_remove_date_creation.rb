class RemoveDateCreation < ActiveRecord::Migration[5.1]
  def change
    remove_column :issues, :date_creation
  end
end
