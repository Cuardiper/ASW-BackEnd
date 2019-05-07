class ApplicationController < ActionController::Base
  include Response
  include ExceptionHandler
  protect_from_forgery with: :exception
  helper_method :current_user

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
  
  def authenticate
  	token = request.headers['token']
  	if(token)
  	  @user = User.where(oauth_token: token).first 
  	else
  	  @user = current_user
  	end
  end
  
  
  
end
