class DashboardController < ApplicationController
  layout "dashboard_layout"
  before_action :require_login
  require "google/cloud/firestore"
  require "aws-sdk-s3"

  #Enumerator.include CoreExtensions::Enumerator::CustomPagination
  def index
    firestore = Google::Cloud::Firestore.new(project_id: ENV["FIRESTORE_PROJECT"], credentials: ENV["FIRESTORE_CREDENTIALS"])
    users_ref = firestore.col("users").get
    @transactions = {}
    users_ref.each do |user|
      transactions_ref = firestore.col("users").doc(user.document_id.to_s).col("transactions").get
      transactions_ref.each do |transaction|
        date = transaction.data[:created_at]
        day = date.strftime("%A")
        if(7.days.ago <= date)
          if @transactions.key?(day)
            @transactions[day] = {total: @transactions[day][:total].to_f + transaction.data[:amount].to_f, day_number: date.wday}
          else
            @transactions[day] = {total: transaction.data[:amount].to_f, day_number: date.wday}
          end
        end
      end
    end
    @transactions = @transactions.sort_by {|key, value| value[:day_number]}
    #logger.debug(@transactions)
  end

  def reviews
    firestore = Google::Cloud::Firestore.new(project_id: ENV["FIRESTORE_PROJECT"], credentials: ENV["FIRESTORE_CREDENTIALS"])
    users_ref = firestore.col("users").get
    @reviews = []
    max = 50
    users_ref.each do |user|
      reviews_ref = firestore.col("users").doc(user.document_id.to_s).col("reviews").get
      reviews_ref.each do |review|
        @reviews.push({email: if user.data[:email].nil? then user.document_id.to_s else user.data[:email].to_s end, review: review})
        #  @reviews[if user.data[:email].nil? then user.document_id.to_s + "-" +  else user.data[:email].to_s end] = review_hash
      end

    end
    @reviews = @reviews.sort {|a, b| b[:review].data[:created_at] <=> a[:review].data[:created_at]}
    #@reviews = Hash[@reviews.sort_by {|key, val| val.data[:created_at]}]
  end

  def cars
    firestore = Google::Cloud::Firestore.new(project_id: ENV["FIRESTORE_PROJECT"], credentials: ENV["FIRESTORE_CREDENTIALS"])
    cars_ref = firestore.col "cars"
    @data = cars_ref.order('make', 'desc').get
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
    end
  end

  def payments
    firestore = Google::Cloud::Firestore.new(project_id: ENV["FIRESTORE_PROJECT"], credentials: ENV["FIRESTORE_CREDENTIALS"])
    users_ref = firestore.col("users").get
    @transactions = Hash.new()
    users_ref.each do |user|
      transactions_ref = firestore.col("users").doc(user.document_id.to_s).col("transactions").get
      if !transactions_ref.nil?
        @transactions[user.document_id.to_s] = {email: user.data[:email].to_s, transactions: transactions_ref}
      end
    end
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
