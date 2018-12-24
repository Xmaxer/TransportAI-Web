class RequestsController < ApplicationController
  layout false
  skip_before_action :verify_authenticity_token, :except => [:car_profits, :get_cars]
  require "google/cloud/firestore"
  require 'json'
  require 'net/http'
  def calculate_price
    if !params[:distance].nil? && !params[:time].nil?
      respond_to do |format|
        distance_price = (params[:distance].to_f * Setting.last.price_per_km.to_f).to_f
        time_price = (params[:time].to_i * Setting.last.price_per_time.to_f).to_f
        format.html {render html: if distance_price > time_price then distance_price.to_s else time_price.to_s end }
      end
    else
      respond_to do |format|
        format.html {render html: "Missing distance (in Kilometers) and/or time (in seconds)"}
      end
    end
  end

  def ardra
    logger.debug("Started request")
    params.each do |key, value|
      logger.debug("Param: #{key} : #{value}")
    end
    code = params[:code]
    car = params[:car]
    if car.nil?
      respond_to do |format|
        format.json {render html: "No car specified"}
        format.html {render html: "No car specified"}
      end
      return
    end
    if !code.nil?
      code = code.to_i
      case code
      when 1
        update_car_location(car)
      when 2
        update_car_location_history(car)
      when 3
        confirm_order(car)
      when 4
        check_order(car)
      when 5
        cancel_order(car)
      when 6
        send_notification(car)
      when 7
        complete_order(car)
      else
        respond_to do |format|
          format.html {render html: "#{code} is not a valid code"}
          format.json {render html: "#{code} is not a valid code"}
        end
      end
    else
      respond_to do |format|
        format.json {render html: "No code specified"}
        format.html {render html: "No code specified"}
      end
    end
  end

  private

  def complete_order(car)
    firestore = Google::Cloud::Firestore.new(project_id: ENV["FIRESTORE_PROJECT"], credentials: ENV["FIRESTORE_CREDENTIALS"])
    cars_ref = firestore.col('cars').doc(car)
    cars_ref.update({status: 4})
  end
  def send_notification(car)
    firestore = Google::Cloud::Firestore.new(project_id: ENV["FIRESTORE_PROJECT"], credentials: ENV["FIRESTORE_CREDENTIALS"])
    cars_ref = firestore.col('cars').doc(car).get
    route_id = cars_ref.data[:route_id]

    make = cars_ref.data[:make]
    model = cars_ref.data[:model]

    route_ref = firestore.col("cars").doc(car).col('routes').doc(route_id).get

    user_id = route_ref.data[:user_id]

    user_ref = firestore.col('users').doc(user_id).get

    notified = user_ref.data[:notified]

    status = cars_ref.data[:status]

    if status == 2
      firestore.col('cars').doc(car).update({status: 3})
    end

    if notified.nil? || notified == false

      token = user_ref.data[:messaging_token]

      title = "Ardra"
      body = "Your " + make.to_s + " " + model.to_s + " has arrived! (#{car})"

      if !token.nil? && !title.nil? && !body.nil?
        url = URI.parse("https://fcm.googleapis.com/fcm/send")
        req = Net::HTTP::Post.new(url)
        req.body = {"data": {"title": title, "body": body},
        "to": token}.to_json

        req.content_type = 'application/json'
        req['authorization'] = ENV['FCM_KEY']

        res = Net::HTTP.start(url.host, url.port, :use_ssl => true) do |http|
          http.request(req)
        end

        respond_to do |format|
          format.json {render json: res.body.to_json}
          format.html {render html: res.body.to_json}
        end
        firestore.col('users').doc(user_id).update({notified: true})
      else
        respond_to do |format|
          format.json {render json: "Missing parameters"}
          format.html {render html: "Missing parameters"}
        end
      end
    else
      respond_to do |format|
        format.json {render json: "Already notified"}
        format.html {render html: "Already notified"}
      end
    end
  end

  def update_car_location(car)
    firestore = Google::Cloud::Firestore.new(project_id: ENV["FIRESTORE_PROJECT"], credentials: ENV["FIRESTORE_CREDENTIALS"])
    cars_ref = firestore.doc "cars/#{car}"

    lat = params[:latitude]
    lng = params[:longitude]

    if lat.nil? || lng.nil?
      respond_to do |format|
        format.json {render html: "latlng not specified correctly"}
        format.html {render html: "latlng not specified correctly"}
      end
      return
    end
    cars_ref.update({location: {latitude: lat.to_f, longitude: lng.to_f}})

    doc = cars_ref.get
    status = doc.data[:status]

    route_id = doc.data[:route_id]

    route_ref = firestore.col('cars').doc(car).col('routes').doc(route_id).get

    if status == 2 || status == 3
      if status == 2
        @destination = route_ref[:origin]
      else if status == 3
        @destination = route_ref[:destination]
      end
      uri = "https://maps.googleapis.com/maps/api/distancematrix/json?units=metric&origins=#{lat},#{lng}&destinations=#{@destination[:latitude]},#{@destination[:longitude]}&key=" + ENV['GOOGLE_API_KEY']
      url = URI.parse(uri)
      req = Net::HTTP::Get.new(url.to_s)
      res = Net::HTTP.start(url.host, url.port, :use_ssl => true){|http|
        http.request(req)
      }

      result = JSON.parse(res.body)
      rows = result["rows"][0]["elements"][0]
      logger.debug(rows)
      if !rows.key?("distance")
        result = -1
      else
        result = result["rows"][0]["elements"][0]["distance"]["value"]
      end

      result = {distance: result}
      respond_to do |format|
        format.json {render json: result.to_json}
        format.html {render html: result.to_json}
      end
    end
  end
  def confirm_order(car)
    firestore = Google::Cloud::Firestore.new(project_id: ENV["FIRESTORE_PROJECT"], credentials: ENV["FIRESTORE_CREDENTIALS"])
    cars_ref = firestore.doc "cars/#{car}"
    cars_ref.update({status: 2})
  end

  def update_car_location_history(car)
    firestore = Google::Cloud::Firestore.new(project_id: ENV["FIRESTORE_PROJECT"], credentials: ENV["FIRESTORE_CREDENTIALS"])
    cars_ref = firestore.col "cars/#{car}/location_history"

    lat = params[:latitude]
    lng = params[:longitude]

    if lat.nil? || lng.nil?
      respond_to do |format|
        format.json {render html: "latlng not specified correctly"}
        format.html {render html: "latlng not specified correctly"}
      end
      return
    end
    cars_ref.add({location: {latitude: lat.to_f, longitude: lng.to_f}, time: firestore.field_server_time })

  end

  def check_order(car)
    firestore = Google::Cloud::Firestore.new(project_id: ENV["FIRESTORE_PROJECT"], credentials: ENV["FIRESTORE_CREDENTIALS"])
    cars_ref = firestore.doc "cars/#{car}"
    data = cars_ref.get

    if data.exists?
      respond_to do |format|
        format.json {render json: data, status: :ok}
        format.html {render json: data, status: :ok}
      end
    else
      respond_to do |format|
        format.json {render html: (data.document_id.to_s + " doesn't exist").html_safe, status: :ok}
        format.html {render html: (data.document_id.to_s + " doesn't exist").html_safe, status: :ok}
      end
    end
  end

  def cancel_order(car)
    firestore = Google::Cloud::Firestore.new(project_id: ENV["FIRESTORE_PROJECT"], credentials: ENV["FIRESTORE_CREDENTIALS"])
    cars_ref = firestore.doc "cars/#{car}"
    cars_ref.update({status: 0})
  end
end
