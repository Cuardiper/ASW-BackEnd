class CreateComments < ActiveRecord::Migration[5.1]
  def change
    create_table :comments do |t|
      t.text :text
      t.integer :reporter_id
      t.integer :issue_id

      t.timestamps
    end
  end
end
