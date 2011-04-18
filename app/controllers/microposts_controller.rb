# Chapt 11.3.1
class MicropostsController < ApplicationController
  before_filter :authenticate
  before_filter :authorized_user, :only => :destroy   # Chapt 11.3.4
  
  def create
    # Chapt 11.3.2
    @micropost = current_user.microposts.build(params[:micropost])
    if @micropost.save
      redirect_to root_path, :flash => { :success => "Micropost created!" }
    else  
      # Not sure why, but I can delete this next line and it still works.
      @feed_items = []
      render 'pages/home'
    end
  end
  
  def destroy
    @micropost.destroy
    redirect_to root_path, :flash => { :success => "Micropost deleted!" }
  end
  
  private
  
    def authorized_user
      @micropost = Micropost.find(params[:id])
      redirect_to root_path unless current_user?(@micropost.user)
    end
end