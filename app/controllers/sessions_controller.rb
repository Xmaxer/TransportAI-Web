class SessionsController < ApplicationController
  def create
    user = User.find_by(username: params[:session][:username].downcase)
    if user && user.authenticate(params[:session][:password])
      log_in(user)
      params[:session][:remember_me] == '1' ? remember(user) : forget(user)
      redirect_to dashboard_url
    else
      #Implement warning when invalid
      # respond_to do |format|
      #   format.js
      # end
      #CREATE 'create.js' in views
      respond_to do |format|
        format.js
      end
    end
  end
  def destroy
    log_out
    redirect_to root_url
  end
end
