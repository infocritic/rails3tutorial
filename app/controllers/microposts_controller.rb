# Chapt 11.3.1
class MicropostsController < ApplicationController
  before_filter :authenticate
  
  def create
    # Chapt 11.3.2
    @micropost = current_user.microposts.build(params[:micropost])
    @micropost.save
    render 'pages/home'
  end
  
  def destroy
    
  end
end