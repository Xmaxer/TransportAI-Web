class DashboardController < ApplicationController
  layout "dashboard_layout"
  before_action :require_login
  def index

  end
  def reviews
    require "google/cloud/firestore"
    firestore = Google::Cloud::Firestore.new(project_id: ENV["FIRESTORE_PROJECT"], credentials: ENV["FIRESTORE_CREDENTIALS"])
    reviews_ref = firestore.col "reviews"
    @data = reviews_ref.get
  end

  private

  def require_login
    unless logged_in?
      render 'static_pages/error'
    end
  end
end
