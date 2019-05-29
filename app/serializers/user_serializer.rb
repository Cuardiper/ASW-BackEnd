class UserSerializer < ActiveModel::Serializer
  attributes :uid, :oauth_token, :id, :name, :email, :foto, :_links#, :issues
  
  def _links
    links = {
      self: { href: "/users/#{object.id}" },
    }
  end
  #def issues
  #  Issue.where(creator_id: object.id)
  #end
end
