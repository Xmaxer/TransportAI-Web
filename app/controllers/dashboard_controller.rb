class DashboardController < ApplicationController
  def index
    if !logged_in?
      render 'static_pages/error'
    end
  end
end
