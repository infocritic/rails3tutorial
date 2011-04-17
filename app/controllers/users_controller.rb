class UsersController < ApplicationController
  # Chapt 10.2.1
  before_filter :authenticate, :only => [:index, :edit, :update, :destroy] 
  before_filter :correct_user, :only => [:edit, :update]
  before_filter :admin_user,   :only => [:destroy]   # Chapt 10.4.2 - Don't really need
                                                     # array brackets since only 1 element
  
  # Chapt 10.3
  def index
    @users = User.paginate(:page => params[:page])  # Chapt 10.3.3
    @title = "All users"
  end
  
  def show
    @user = User.find(params[:id])
    @microposts = @user.microposts.paginate(:page => params[:page])        # Chapt 11.2.1
    @title = @user.name 
  end
  
  def new
    @user = User.new
    @title = "Sign up"
  end
  
  def create
    @user = User.new(params[:user])
    if @user.save
      sign_in @user
      flash[:success] = "Welcome to the Sample App!"
      redirect_to @user
    else
      @title = "Sign up"
      render 'new'
    end
  end

  def edit
    # Take note of the next line: it raises an exception in the browser
    # -- Great way to quickly get feedback during debugging.
    # raise request.inspect
    
    # Chapt 10.4.2 REFACTOR - Don't need @user assignment as it is 
    # handled as part of the correct_user before_filter. Instead
    # of removing the line, it s commented out for training purposes.
    # @user = User.find(params[:id])
    @title = "Edit user"
  end
  
  def update
    # Chapt 10.4.2 REFACTOR - Don't need @user assignment as it is 
    # handled as part of the before_filter defined correct_user 
    # method for both the edit and update actions. Instead of
    # removing the line, it s commented out for training purposes.
    # @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      flash[:success] = "Profile updated."
      redirect_to @user
    else
      @title = "Edit user"
      render 'edit'
    end
  end
  
  # Chapt 10.4.2
  def destroy
    @user.destroy
    flash[:success] = "User destroyed."
    redirect_to users_path
  end
  
  private
  
  # Chapt 10.2.1
  def authenticate
    # deny_access is in sessions_helper.rb
    deny_access unless signed_in?
  end
  
  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_path) unless current_user?(@user)
  end
  
  # Chapt 10.4.2
  # The redirect_to line will send the user to the root_path unless
  # the current user is an admin.  But if the user being deleted
  # is also the 'current_user' (the live person using the app)
  # then also redirect_to root_path.  In other words, a user,
  # even if she is an admin cannot delete themself.
  # Chapt 11.1.3 REFACTOR -- Changed user to @user to remove the
  # need to hit the database again in the destroy method of this
  # controller
  def admin_user
    @user = User.find(params[:id])
    # redirect_to(root_path) unless ( current_user.admin? && !current_user?(user) )
    # ----------- OR ------------
    redirect_to(root_path) if ( !current_user.admin? || current_user?(@user) )
  end
end
