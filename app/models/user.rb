class User < ApplicationRecord
  has_many :issues
  validates :email, presence: true

end
