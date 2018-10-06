class SessionsController < ApplicationController
  def create
    user = User.find_by(username: params[:session][:username].downcase)
    if user && user.authenticate(params[:session][:password])
      login(user)
      redirect_to dashboard_url
    else
      flash.now[:danger] = 'Invalid username/password combination'
      render 'static_pages/login'
    end
  end
  def destroy
    log_out
    redirect_to root_url
  end
end
