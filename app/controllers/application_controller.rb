class ApplicationController < ActionController::Base
  protect_from_forgery
  # Chapt 9.3.2
  include SessionsHelper
end
