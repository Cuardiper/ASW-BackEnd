class User < ApplicationRecord
  has_many :assigned_issues, class_name: 'Issue'
  validates :email, presence: true

end
