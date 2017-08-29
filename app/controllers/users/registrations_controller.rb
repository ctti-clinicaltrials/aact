class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_devise_permitted_parameters, if: :devise_controller?
  #before_filter :configure_permitted_parameters

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

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up).push(:first_name, :last_name, :email, :password, :password_confirmation)
  end
end

