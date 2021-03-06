class User < ApplicationRecord
  validates :uid, presence: true
  has_many :issues
  has_many :comments
  has_and_belongs_to_many :watched, class_name: 'Issue'
  has_many :votos
  
  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_initialize.tap do |user|
      user.provider = auth.provider
      user.uid = auth.uid
      user.name = auth.info.name
      user.email = auth.info.email
      user.foto = auth.info.image
      user.oauth_token = auth.uid
      user.oauth_expires_at = Time.at(auth.credentials.expires_at)
      user.save!
    end
  end
  
end

