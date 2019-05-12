class IssueSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :type_issue, :priority, :status, :votes, :creator_id, :assignee_id, :created_at, :updated_at, :_links
  
  def _links
    if object.assignee_id != nil
      links = {
        self: { href: "/issues/#{object.id}" },
        creator: { href: "/users/#{object.creator_id}"},
        assignee: { href: "/users/#{object.assignee_id}"},
        comments: { href: "/issues/#{object.id}/comments"}
      }
    else
      links = {
        self: { href: "/issues/#{object.id}" },
        creator: { href: "/users/#{object.creator_id}", id: object.creator_id, name: User.find(object.creator_id).name },
        assignee: { href: nil, id: nil, name: nil },
        comments: { href: "/issues/#{object.id}/comments"}
      }
    end
  end
end
