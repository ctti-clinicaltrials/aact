class CredentialsController < ApplicationController
  #before_action :configure_devise_permitted_parameters, if: :devise_controller?
  before_action :authenticate_user!

  protected

  def configure_devise_permitted_parameters
    registration_params = [:first_name, :last_name, :email, :password, :password_confirmation, :current_password]

    if params[:action] == 'update'
      devise_parameter_sanitizer.permit(:account_update) {
        |u| u.permit(registration_params)
        #|u| u.permit(registration_params << :current_password)
      }
    elsif params[:action] == 'create'
      devise_parameter_sanitizer.permit(:sign_up) {
        |u| u.permit(registration_params)
      }
    end
  end

end
