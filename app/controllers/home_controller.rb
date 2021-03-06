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
    puts "retain set to #{@retain}"
    
    
    if @expedia == 'on'
      @payment_type = 'Expedia'
      @url_ext = "receivers/#{ENV['EXPEDIA']}/deliver.json"
      req = JSON.dump({
        "delivery" => {
          "payment_method_token" => "#{@token}",
          "url" => "https://spreedly-echo.herokuapp.com",
          "headers" => "Content-Type: application/json",
          "body" => {
            "product_id" => "91653",
            "card_number" => "{{ credit_card_number }}"
          }
        }
      })
    else
      @payment_type = 'Spreedly'
      @url_ext = "gateways/#{ENV['TEST_GATEWAY_TOKEN']}/purchase.json"
      req = JSON.dump({
        "transaction" => {
          "payment_method_token" => "#{@token}",
          "amount" => @amount,
          "currency_code" => "USD",
          "retain_on_success" => @retain
        }
      })
    end

    
    uri = URI.parse("https://core.spreedly.com/v1/#{@url_ext}")
    request = Net::HTTP::Post.new(uri)
    request.basic_auth("#{ENV['ENV_KEY']}", "#{ENV['ACCESS_SECRET']}")
    request.content_type = "application/json"
    request.body = req
    req_options = {
      use_ssl: uri.scheme == "https",
    }
    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end
    body = JSON.parse(response.body)
    if body["transaction"]["succeeded"] != true
      @success = "TAKE A HIKE, BUB"
    else
      @success = "Welcome to the sky"
    end
    puts "I AM RESPONSE:"
    puts body
    @temp = body["transaction"]["token"]
    record = Transaction.new()
    record.flight_name = @flight.route
    record.date = body["transaction"]["created_at"]
    record.last_four = body["transaction"]["payment_method"]["last_four_digits"]
    record.amount = @flight.price
    record.saved = @retain
    record.gateway_type = @payment_type
    record.save
  end
end
