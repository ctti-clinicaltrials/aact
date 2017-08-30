class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  layout "application"
  protect_from_forgery with: :exception

end
