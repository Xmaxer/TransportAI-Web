class UsersController < ApplicationController
  def new
    if !logged_in? && User.count >= 1
      render 'static_pages/error'
  else
    @user = User.new
  end
  end
  def create
    @user = User.new(user_params)
    if @user.save
      if !logged_in?
        log_in @user
      end
      redirect_to dashboard_url
    else
      render 'new'
    end
  end

  def user_params
    params.require(:user).permit(:username, :password, :password_confirmation, :first_name, :second_name)
  end
end
