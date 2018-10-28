class StaticPagesController < ApplicationController
  layout false, only: [:error]
  def error
  end
  def home
  end

  def login
    if logged_in?
      redirect_to dashboard_url
    end
  end
end
