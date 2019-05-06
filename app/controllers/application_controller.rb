class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  helper_method :current_user

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
  
  def authenticate
  	token = request.headers['token']
  	@user = User.where(oauth_token: token).first if token
  end
  
  
  
end
