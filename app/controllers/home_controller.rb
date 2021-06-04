class HomeController < ApplicationController
  skip_before_action :verify_authenticity_token
  require 'net/http'
  require 'uri'
  require 'json'

  def index
    @flights = Flight.all
  end

  def show
    @flight = Flight.find(params[:id])
    @amount = @flight.price*100
  end

  def purchase
    @flight = Flight.find(params[:id])
    @amount = (@flight.price*100).to_i
    # make gateway token if/else for expedia 
    @gateway_token = ENV['TEST_GATEWAY_TOKEN']
    @token = params[:payment_method_token]
    # placeholder retain payment
    @retain = true
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
  end
end
