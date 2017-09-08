class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_devise_permitted_parameters, if: :devise_controller?

  def destroy
    current_user.remove
    render 'pages/home'
  end

  protected

  def update_resource(resource, params)
    resource.update(params)
  end

  def configure_devise_permitted_parameters
    registration_params = [:first_name, :last_name, :email, :password, :password_confirmation, :current_password]

    case params[:action]
    when 'update'
      devise_parameter_sanitizer.permit(:account_update) {
        |u| u.permit(registration_params << :current_password)
      }
    when 'create'
      devise_parameter_sanitizer.permit(:sign_up) {
        |u| u.permit(registration_params)
      }
    end
  end

  def configure_permitted_parameters
    params.permit user: [:first_name, :last_name, :email, :password, :password_confirmation]
    devise_parameter_sanitizer.for(:sign_up).push(:first_name, :last_name, :email, :password, :password_confirmation)
  end
end

