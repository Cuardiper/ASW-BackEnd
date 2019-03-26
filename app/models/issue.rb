class Issue < ApplicationRecord
    validates :description, length: { maximum: 140 }
    belongs_to :creator, class_name: 'User'
    belongs_to :assignee, class_name: 'User'
end
