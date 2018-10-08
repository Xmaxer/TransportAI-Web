module SessionsHelper

  def login(user)
    session[:user_id] = user.id
  end

  def current_user
    if session[:user_id]
      @current_user ||= User.find_by(id: session[:user_id])
    elsif cookies.signed[:used_id]
      user = User.find(id: cookies.signed[:used_id])
      if user && user.authenticated?(cookies[:remember_token])
        login user
        @current_user = user
      end
    end
  end

  def logged_in?
    !current_user.nil?
  end

  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  def remember(user)
    user.remember
    cookies.permanent.signed[:used_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end
  def log_out
    session.delete(:user_id)
    @current_user = nil
  end
end
