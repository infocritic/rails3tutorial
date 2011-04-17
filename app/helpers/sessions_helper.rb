module SessionsHelper
  
  def sign_in(user)
    # Pre Rails 3 way of doing this...
    # cookies[:remember_token] = {:value => user.id,
    #                             :expires => 20.years.from_now.utc }
    
    cookies.permanent.signed[:remember_token] = [user.id, user.salt]
    current_user = user
  end
  
  def signed_in?
    !current_user.nil?
  end
  
  def sign_out
    cookies.delete(:remember_token)
    current_user = nil
  end
  
  def current_user=(user)
    @current_user = user
  end
  
  def current_user
    @current_user ||= user_from_remember_token
  end
  
  def current_user?(user)
    user == current_user
  end
  
  # Chapt 10.2.1
  # Chapt 11.3.1 REFACTOR  - Moved method from users_controller
  # to allow use from micoposts_controller as well as the
  # users_controller
  def authenticate
    # deny_access is in sessions_helper.rb
    deny_access unless signed_in?
  end

  def deny_access
    store_location
    # flash[:notice] = "Please sign in to access this page."
    # redirect_to signin_path
    # ------- OR -------
    redirect_to signin_path, :notice => "Please sign in to access this page."
  end
  
  #Chapt 10.2.3
  def store_location
    session[:return_to] = request.fullpath
  end
  
  def redirect_back_or(default)
    redirect_to(session[:return_to] || default)
    clear_return_to
  end
  
  # We have to clear the stored :return_to 'value' in the session cookie
  # or the next time redirect_back_or is hit, it will continue to route
  # to the same page originally stored in :return_to, which we do not want.
  # Chapt 10.2.3
  def clear_return_to
    session[:return_to] = nil    
  end
  
  private
  
    # Chapt 9.3.3
    def user_from_remember_token
      # * - flattens an array into the individual items
      User.authenticate_with_salt(*remember_token)   
    end
    
    def remember_token
      cookies.signed[:remember_token] || [nil, nil]
    end
end
