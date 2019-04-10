class Issue < ApplicationRecord
    validates :title, presence: true, length: { maximum: 140 }
    validates :description, length: { maximum: 300 }
    belongs_to :creator, class_name: 'User'
    belongs_to :assignee, optional: true, class_name: 'User'
    has_many :comments
    has_many :attachments
    has_and_belongs_to_many :watchers, class_name: 'User'
    has_many :votes, dependent: :destroy
    
    scope :status, -> (status) { where(status: status) if status.present? }
    scope :priority, -> (priority) { where(priority: priority) if priority.present? }
    scope :type_issue, -> (type_issue) { where(type_issue: type_issue) if type_issue.present? }
    scope :assignee_id, -> (assignee_id) { where(assignee_id: assignee_id) if assignee_id.present? }
    
end
