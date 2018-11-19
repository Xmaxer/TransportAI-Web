class RequestsController < ApplicationController
  layout false
  skip_before_action :verify_authenticity_token
  require "google/cloud/firestore"

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
      else
        respond_to do |format|
          format.json {render html: "#{code} is not a valid code"}
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
    cars_ref.set({location: {latitude: lat.to_f, longitude: lng.to_f}}, merge: true)
  end

  def confirm_order(car)
    firestore = Google::Cloud::Firestore.new(project_id: ENV["FIRESTORE_PROJECT"], credentials: ENV["FIRESTORE_CREDENTIALS"])
    cars_ref = firestore.doc "cars/#{car}"
    cars_ref.set({status: 2}, merge: true)
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
        format.json {render html: data.data[:status], status: :ok}
        format.html {render html: data.data[:status], status: :ok}
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
    cars_ref.set({status: 0}, merge: true)
  end
end
