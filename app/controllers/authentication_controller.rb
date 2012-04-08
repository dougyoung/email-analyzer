class AuthenticationController < ApplicationController

  before_filter :login
  after_filter :logout

  private
  
  def login
    @gmail = Gmail.new(params[:username], 'OBSCURED')
  end

  def logout
    @gmail.logout
  end
  
end