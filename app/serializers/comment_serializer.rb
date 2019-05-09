class CommentSerializer < ActiveModel::Serializer
  attributes :id, :text, :reporter_id, :issue_id, :created_at, :updated_at, :_links
  
  def _links
    links = {
      self: { href: "/comments/#{object.id}" },
      reporter: { href: "/users/#{object.reporter_id}"},
      issue: { href: "/issues/#{object.issue_id}"}
    }
  end
end
