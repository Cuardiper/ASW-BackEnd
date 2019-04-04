class Comment < ApplicationRecord
  belongs_to :reporter, class_name: 'User'
  belongs_to :issue
end
