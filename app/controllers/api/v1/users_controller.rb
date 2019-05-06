class Api::V1::UsersController < ApplicationController
  before_action :set_todo, only: [:show, :update, :destroy]

  # GET /users
  def index
    @users = User.all
    json_response(@users)
  end
  
  # GET /users/1
  def show
    json_response(@user)
  end
  
  # PUT/PATCH /users/1
  def update
    @user.update(todo_params)
    head :no_content
  end
  
  def destroy
    @todo.destroy
    head :no_content
  end
  
  private

  def todo_params
    # whitelist params
    params.permit(:title, :created_by)
  end

  def set_todo
    @user = User.find(params[:id])
  end
  
end