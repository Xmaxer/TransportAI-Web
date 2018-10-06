class UsersController < ApplicationController
  def new
    @user = User.new
  end
  def create
    @user = User.new(user_params)
    if @user.save
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
