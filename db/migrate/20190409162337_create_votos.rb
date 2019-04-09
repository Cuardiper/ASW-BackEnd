class CreateVotos < ActiveRecord::Migration[5.1]
  def change
      create_table :issues_users_votes, id: false do |t|
      t.belongs_to :issue, index: true
      t.belongs_to :user, index: true
    end
  end
end
