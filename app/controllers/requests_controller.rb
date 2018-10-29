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
        format.json {render html: res}
      end
    else
      respond_to do |format|
        format.json {render html: "No car specified"}
      end
    end
  end
end
