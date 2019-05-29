class SessionsController < ApplicationController
  
  def create
    user = User.from_omniauth(request.env["omniauth.auth"])
    userAux = User.where(email: "carles.farre@gmail.com")
    userAux.update(oauth_token: "103078372808824005733")
    session[:user_id] = user.id
    #render json: user.oauth_token
    redirect_to issues_path
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path
  end

end