class Drop < ActiveRecord::Migration[5.1]
  def change
    drop_table :issues_users_votes
  end
end
