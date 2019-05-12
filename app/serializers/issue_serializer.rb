class IssueSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :type_issue, :priority, :status, :votes, :watches, :creator_id, :assignee_id, :created_at, :updated_at, :voters, :watchers, :_links
  
  def watches
    @issue = Issue.find(object.id)
    @issue.watchers.count()
  end
  
  def watchers
    @issue = Issue.find(object.id)
    @issue.watchers.pluck(:id, :name)
  end
  
  def voters
    @result = []
    #@votos = Voto.where(:issue_id => object.id)
    Voto.where(:issue_id => object.id).each do |v|
      @aux = User.where(:id => v.user_id).pluck(:id, :name)
      @result.push(@aux)
    end
    return @result
  end
  
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
