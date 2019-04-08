class CreateWatch < ActiveRecord::Migration[5.1]
  def change
      create_table :watches, id: false do |t|
      t.belongs_to :issue, index: true
      t.belongs_to :user, index: true
    end
  end
end
