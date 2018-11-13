class RequestsController < ApplicationController
  layout false
  skip_before_action :verify_authenticity_token
  def update_car_location
    require 'net/http'
    car = params[:car]
    if car
      uri = URI("https://firestore.googleapis.com/v1beta1/projects/transport-ai-1537358687680/databases/(default)/documents/cars/#{car}?updateMask.fieldPaths=location&key=AIzaSyC6MpEIqlVRJSLrj1jxKGadGIZF_JmmHoU")
      req = Net::HTTP::Patch.new(uri)

      content = request.body.read
      req.body = content
      req.content_type = 'application/json'
      res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => true) do |http|
        http.request(req)
      end
      respond_to do |format|
        format.json {render html: res, status: :ok}
      end
    else
      respond_to do |format|
        format.json {render html: "No car specified"}
      end
    end
  end

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

  def confirm_order
    require 'net/http'
    car = params[:car]
    if car
      uri = URI("https://firestore.googleapis.com/v1beta1/projects/transport-ai-1537358687680/databases/(default)/documents/cars/#{car}?updateMask.fieldPaths=status&key=AIzaSyC6MpEIqlVRJSLrj1jxKGadGIZF_JmmHoU")
      req = Net::HTTP::Patch.new(uri)

      content = request.body.read
      req.body = content
      req.content_type = 'application/json'
      res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => true) do |http|
        http.request(req)
      end
      respond_to do |format|
        format.json {render html: res, status: :ok}
      end
    else
      respond_to do |format|
        format.json {render html: "No car specified"}
      end
    end
  end
end
