class UserSerializer < ActiveModel::Serializer
  attributes :oauth_token, :id, :name, :email, :foto, :issues
  
  def issues
     Issue.where(creator_id: object.id)
  end
end
