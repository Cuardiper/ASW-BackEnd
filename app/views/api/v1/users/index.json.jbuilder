json.array! @users do |user|
  json.(user, :id, :email, :name)
end