class ApplicationController < ActionController::Base
  protect_from_forgery

  def store_location
    session[:return_to] = request.url
  end
  
end
