class Users::RegistrationsController < Devise::RegistrationsController
  before_filter :save_password, :only => [ :new, :create ]
  before_action :configure_devise_permitted_parameters, if: :devise_controller?

  def destroy
    current_user.remove
    render 'pages/home'
  end

  protected

  def save_password
    params[:user][:unencrypted_password]=params[:user][:password] if params[:action]=='create' and params[:user][:password]
  end

  def update_resource(resource, params)
    resource.update(params) if !params[:current_password].blank?
  end

  def configure_devise_permitted_parameters
    registration_params = [:first_name, :last_name, :email, :db_username, :password, :password_confirmation, :current_password, :unencrypted_password]

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
    params.permit user: [:first_name, :last_name, :email, :db_username, :password, :password_confirmation, :unencrypted_password]
    devise_parameter_sanitizer.for(:sign_up).push(:first_name, :last_name, :email, :db_username, :password, :password_confirmation)
  end
end

