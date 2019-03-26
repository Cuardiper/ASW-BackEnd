json.extract! issue, :id, :title, :description, :type_issue, :priority, :status, :votes, :creator_id, :assignee_id, :created_at, :updated_at
json.url issue_url(issue, format: :json)
