class HomeController < ApplicationController
  skip_before_action :verify_authenticity_token
  require 'net/http'
  require 'uri'
  require 'json'

  def index
    @flights = Flight.all
  end

  def transactions
    @transactions = Transaction.all
  end

  def show
    @flight = Flight.find(params[:id])
    @amount = @flight.price*100
  end

  def purchase
    @flight = Flight.find(params[:id])
    @amount = (@flight.price*100).to_i
    @token = params[:payment_method_token]
    @expedia = params[:expedia]
    @retain = params[:retain]
    # pretain payment
    if @retain == 'on'
      @retain = true
    else
      @retain = false
    end
    
    
    if @expedia == 'on'
      @payment_type = 'Expedia'
      @gateway_token = ENV['EXPEDIA']
    else
      @payment_type = 'Spreedly'
      @gateway_token = ENV['TEST_GATEWAY_TOKEN']
    end

    puts "retain set to #{@retain}"
    # Below sends/recieves requests
    uri = URI.parse("https://core.spreedly.com/v1/gateways/#{@gateway_token}/purchase.json")
    request = Net::HTTP::Post.new(uri)
    request.basic_auth("#{ENV['ENV_KEY']}", "#{ENV['ACCESS_SECRET']}")
    request.content_type = "application/json"
    request.body = JSON.dump({
      "transaction" => {
        "payment_method_token" => "#{@token}",
        "amount" => @amount,
        "currency_code" => "USD",
        "retain_on_success" => @retain
      }
    })
    req_options = {
      use_ssl: uri.scheme == "https",
    }
    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end
    body = JSON.parse(response.body)
    puts body["transaction"]["token"]
    @temp = body["transaction"]["token"]
    puts @payment_type
    record = Transaction.new()
    record.flight_name = @flight.route
    record.date = body["transaction"]["created_at"]
    record.last_four = body["transaction"]["last_four_digits"]
    record.amount = @flight.price
    record.saved = @retain
    record.gateway_type = @payement_type
    record.save
  end
end
