module SessionsHelper
  
  def sign_in(user)
    # Pre Rails 3 way of doing this...
    # cookies[:remember_token] = {:value => user.id,
    #                             :expires => 20.years.from_now.utc }
    
    cookies.permanent.signed[:remember_token] = [user.id, user.salt]
    current_user = user
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
  
  def signed_in?
    !current_user.nil?
  end
  
  private
  
    def user_from_remember_token
      # * - flattens an array into the individual items
      User.authenticate_with_salt(*remember_token)   
    end
    
    def remember_token
      cookies.signed[:remember_token] || [nil, nil]
    end
end
