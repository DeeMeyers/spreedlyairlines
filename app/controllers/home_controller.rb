class HomeController < ApplicationController
  def index
    @flights = Flight.all
  end
end
