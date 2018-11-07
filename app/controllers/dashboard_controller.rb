class DashboardController < ApplicationController
  layout "dashboard_layout"
  before_action :require_login
  require "google/cloud/firestore"
  require "aws-sdk-s3"

  Enumerator.include CoreExtensions::Enumerator::CustomPagination
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
    # if !params[:start_at].nil?
    #   params[:start_at] = eval(params[:start_at])
    #   @data = cars_ref.order('make', 'desc').order('model', 'desc').start_after([params[:start_at][:make].to_s, params[:start_at][:model].to_s]).limit(2).get
    # else
    #   @data = cars_ref.order('make', 'desc').order('model', 'desc').limit(2).get
    # end
    # @start_at = {}
    # @data.each do |d|
    #   @start_at[:make] = d.data[:make]
    #   @start_at[:model] = d.data[:model]
    # end
    @data = cars_ref.order('make', 'desc').get
    #@data = @data.paginate(@data, {page: params[:page], per_page: 2})
  end

  def submit_car
    if ((params[:car_details][:make].present?) && (params[:car_details][:model].present?) && (params[:car_details][:seats].to_i.is_a? Integer) && (params[:car_details][:number_plate].present?))
      firestore = Google::Cloud::Firestore.new(project_id: ENV["FIRESTORE_PROJECT"], credentials: ENV["FIRESTORE_CREDENTIALS"])
      doc = firestore.doc "cars/" + params[:car_details][:number_plate]
      #img = params[:car_details][:image]
      filename = (params[:car_details][:make].to_s + "_" + params[:car_details][:model].to_s + ".jpg").downcase
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
        image: if !file_exists?(filename) then 'default.jpg' else filename end
      }
      doc.set data

      # if !img.nil?
      #   bucket = 'ardra'
      #   bucket_obj = Aws::S3::Resource.new.bucket(bucket)
      #   obj = bucket_obj.object('public/cars/' + File.basename(img.original_filename))
      #   obj.upload_file(img.tempfile)
      #   client = Aws::S3::Client.new
      #   client.put_object_acl({
      #     bucket: bucket,
      #     acl: "public-read",
      #     key: 'public/cars/' + File.basename(img.original_filename)
      #     })
      #   end
    end
    # File.open(Rails.root.join('public', 'cars', img.original_filename), "wb") do |file|
    #   file.write(img.read)
    # end
  end

  def payments

  end

  def routes

  end

  def settings
    @setting = current_user.settings.new(price_per_km: if Setting.first.nil? then 0 else Setting.last.price_per_km.to_f end,
    price_per_time: if Setting.first.nil? then 0 else Setting.last.price_per_time.to_f end)
    @current_distance_price = (1 * if Setting.first.nil? then 0 else Setting.last.price_per_km.to_f end).to_f
    @current_time_price = (60 * if Setting.first.nil? then 0 else Setting.last.price_per_time.to_f end).to_f
  end

  def new_setting
    @setting = current_user.settings.build(setting_params)
    @setting.save
    redirect_to dashboard_settings_url
  end
  private
  def setting_params
    params.require(:setting).permit(:price_per_km, :price_per_time)
  end
  def file_exists?(filename)
    require "net/http"
    url = URI.parse(ENV['AWS_ENDPOINT'] + filename)
    req = Net::HTTP.new(url.host, url.port)
    res = req.request_head(url.path)
    logger.debug(res.code)
    res.code == "304" || res.code == "200"
  end

  def require_login
    unless logged_in?
      #head 404
      #render status: 404, :layout => false
      render 'errors/forbidden', layout: false
    end
  end
end
