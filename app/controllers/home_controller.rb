class HomeController < ApplicationController
  def show
    if current_user
      redirect_to issues_path
    end
  end
end
