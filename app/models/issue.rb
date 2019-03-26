class Issue < ApplicationRecord
    validates :description, length: { maximum: 140 }
    belongs_to :creator_id
    has_one :assignee_id
end
