# Chapt 9.1.1
class SessionsController < ApplicationController
  
  def new
    @title = "Sign in"
  end
  
  # Chapt 9.2.2
  def create
    user = User.authenticate(params[:session][:email],
                             params[:session][:password])
    if user.nil?
      @title = 'Sign in'
      flash.now[:error] = "Invalid email/password combination."
      render'new'
    else
      sign_in user
      redirect_back_or user
    end
  end
  
  # Chapt 9.4.1
  def destroy
    sign_out
    redirect_to root_path
  end
end
