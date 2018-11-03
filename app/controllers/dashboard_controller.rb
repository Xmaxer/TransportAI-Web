class DashboardController < ApplicationController
  layout "dashboard_layout"
  before_action :require_login
  require "google/cloud/firestore"
  require "aws-sdk-s3"
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
    if ((params[:car_details][:make].present?) && (params[:car_details][:model].present?) && (params[:car_details][:seats].to_i.is_a? Integer) && (params[:car_details][:number_plate].present?))
      logger.debug("HELLO")
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
        image: if img.nil? then 'default.jpg' else img.original_filename end
      }
      doc.set data

      if !img.nil?
        bucket = 'ardra'

        bucket_obj = Aws::S3::Resource.new.bucket(bucket)
        obj = bucket_obj.object('public/cars/' + File.basename(img.original_filename))
        obj.upload_file(img.tempfile)
        client = Aws::S3::Client.new
        client.put_object_acl({
          bucket: bucket,
          acl: "public-read",
          key: 'public/cars/' + File.basename(img.original_filename)
          })
        end
      end
      # File.open(Rails.root.join('public', 'cars', img.original_filename), "wb") do |file|
      #   file.write(img.read)
      # end
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
