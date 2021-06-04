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
    @amount = @flight.price*100
    @gateway_token = ENV['GATEWAY_TOKEN']
    puts @gateway_token
    @envkey = ENV['ENV_KEY']
    puts @envkey
    @secret = ENV['ACCESS_SECRET']
    puts @secret
    @token = params[:payment_method_token]
    puts @token
    uri = URI.parse("https://core.spreedly.com/v1/gateways/#{@gateway_token}/purchase.json")
    request = Net::HTTP::Post.new(uri)
    request.basic_auth("#{@envkey}", "#{@secret}")
    request.content_type = "application/json"
    request.body = JSON.dump({
      "transaction" => {
        "payment_method_token" => "#{@token}",
        "amount" => @amount,
        "currency_code" => "USD",
        "retain_on_success" => true
      }
    })

    req_options = {
      use_ssl: uri.scheme == "https",
    }
    puts request.body
    
    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end
    puts response.body
    
  end

end
