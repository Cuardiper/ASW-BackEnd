class UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :email, :foto, :issues
  def issues
     Issue.where(creator_id: object.id)
  end
end
