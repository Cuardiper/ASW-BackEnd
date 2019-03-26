class CreateIssues < ActiveRecord::Migration[5.1]
  def change
    create_table :issues do |t|
      t.text :title
      t.text :description
      t.text :type
      t.text :priority
      t.text :status
      t.integer :votes
      t.integer :creator_id
      t.integer :assignee_id
      t.date :date_creation
      t.timestamps
    end
  end
end
