json.extract! user, :id, :name, :email, :created_at, :updated_at, :issues
json.url user_url(user, format: :json)
