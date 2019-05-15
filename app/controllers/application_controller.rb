class ApplicationController < ActionController::Base
  include Response
  include ExceptionHandler
  protect_from_forgery with: :exception
  helper_method :current_user

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
  
  def authenticate
  	token2 = request.headers['token']
  	if(token2)
  	  @user = User.where(oauth_token: token2).first
  	else
  	  @user = current_user
  	end
  end
  
  
  
end
