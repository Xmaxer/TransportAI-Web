class ApiController < ApplicationController
  layout false
  require "google/cloud/firestore"
  def get_cars
    firestore = Google::Cloud::Firestore.new(project_id: ENV["FIRESTORE_PROJECT"], credentials: ENV["FIRESTORE_CREDENTIALS"])
    cars_ref = firestore.col("cars").get
    cars = {cars: []}
    cars_ref.each do |car|
      cars[:cars].push({name: car.data[:make] + " " + car.data[:model], license_plate: car.document_id.to_s})
    end

    respond_to do |format|
      format.json {render json: cars.to_json}
      format.html {render html: cars.to_json}
    end
  end
  def car_profits
    car = params[:car]
    if car
      firestore = Google::Cloud::Firestore.new(project_id: ENV["FIRESTORE_PROJECT"], credentials: ENV["FIRESTORE_CREDENTIALS"])
      cars_ref = firestore.col("cars").doc(car).col("routes").get
      routeIds = []
      cars_ref.each do |car|
        routeIds.push(car.document_id.to_s)
      end

      users_ref = firestore.col("users").get
      @transactions = {}
      users_ref.each do |user|
        transactions_ref = firestore.col("users").doc(user.document_id.to_s).col("transactions").get
        transactions_ref.each do |transaction|
          date = transaction.data[:created_at]
          day = date.strftime("%A")
          route_id = transaction.data[:route_id].to_s
          if(7.days.ago <= date && routeIds.include?(route_id))
            if @transactions.key?(day)
              @transactions[day] = {total: @transactions[day][:total].to_f + transaction.data[:amount].to_f, day_number: date.wday}
            else
              @transactions[day] = {total: transaction.data[:amount].to_f, day_number: date.wday}
            end
          end
        end
      end
      @transactions = Hash[@transactions.sort_by {|key, value| value[:day_number]}]
      respond_to do |format|
        format.json {render json: @transactions.to_json}
        format.html {render html: @transactions.to_json}
      end
    end
  end
end
