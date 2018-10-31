class DashboardController < ApplicationController
  layout "dashboard_layout"
  before_action :require_login
  require "google/cloud/firestore"
  def index

  end
  def reviews
    firestore = Google::Cloud::Firestore.new(project_id: ENV["FIRESTORE_PROJECT"], credentials: ENV["FIRESTORE_CREDENTIALS"])
    reviews_ref = firestore.col "reviews"
    @data = reviews_ref.order('created_at', 'desc').limit(10).get
  end

  def cars
    firestore = Google::Cloud::Firestore.new(project_id: ENV["FIRESTORE_PROJECT"], credentials: ENV["FIRESTORE_CREDENTIALS"])
    cars_ref = firestore.col "cars"
    @data = cars_ref.get
  end

  def submit_car
    firestore = Google::Cloud::Firestore.new(project_id: ENV["FIRESTORE_PROJECT"], credentials: ENV["FIRESTORE_CREDENTIALS"])
    doc = firestore.doc "cars/" + params[:car_details][:number_plate]
    img = params[:car_details][:image]
    data = {
      make: params[:car_details][:make],
      model: params[:car_details][:model],
      location: {
        longitude: 0,
        latitude: 0
      },
      route_id: nil,
      status: 0,
      seats: params[:car_details][:seats].to_i,
      image: img.original_filename
    }
    doc.set data
    File.open(Rails.root.join('public', 'cars', img.original_filename), "wb") do |file|
      file.write(img.read)
    end
  end
  private

  def require_login
    unless logged_in?
      #head 404
      #render status: 404, :layout => false
      render 'errors/forbidden', layout: false
    end
  end
end
