class AuthenticationController < ApplicationController

  before_filter :login
  after_filter :logout

  private

  def require_password
    unless logged_in?
      store_location
      redirect_to enter_password_path
      false
    end
  end

  def login
    @gmail = Gmail.new(params[:username], 'OBSCURED')
  end

  def logged_in?
    return false if @gmail.nil? || !@gmail.logged_in?
  end

  def logout
    @gmail.logout
  end

end