class AttachmentSerializer < ActiveModel::Serializer
  attributes :id, :issue_id, :created_at, :updated_at, :file_file_name, :file_file_size, :_links
  
  def _links
    links = {
      self: { href: "/attachments/#{object.id}" },
      url: { href: object.file.url},
      issue: { href: "/issues/#{object.issue_id}"}
    }
  end
  
end