json.extract! comment, :id, :text, :reporter_id, :issue_id, :created_at, :updated_at
json.url comment_url(comment, format: :json)
