class Issue < ApplicationRecord
    validates :title, presence: true, length: { maximum: 140 }
    validates :description, length: { maximum: 300 }
    belongs_to :creator, class_name: 'User'
    belongs_to :assignee, optional: true, class_name: 'User'
end
