class Issue < ApplicationRecord
    validates :description, length: { maximum: 140 }
  belongs_to :user, class_name: 'User', foreign_key: 'user_id'
  belongs_to :assignee, optional: true, class_name: 'User', foreign_key: 'assignee_id'
end
