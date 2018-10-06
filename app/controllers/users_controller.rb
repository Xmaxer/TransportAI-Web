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
        login @user
      end
      flash[:success] = "New user added successfully"
      redirect_to dashboard_url
    else
      render 'new'
    end
  end

  def user_params
    params.require(:user).permit(:username, :password, :password_confirmation)
  end
end
