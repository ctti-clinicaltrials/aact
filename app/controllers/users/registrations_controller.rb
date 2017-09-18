class Users::RegistrationsController < Devise::RegistrationsController
  before_filter :save_password, :only => [ :new, :create ]
  before_action :configure_devise_permitted_parameters, if: :devise_controller?

  def create
    super
    notify_user_of_email_confirmation if !resource.errors.any?
  end

  def destroy
    current_user.remove
    redirect_to root_path
  end

  protected

  def save_password
    params[:user][:unencrypted_password]=params[:user][:password] if params[:action]=='create' and params[:user][:password]
  end

  def update_resource(resource, params)
    if params[:current_password].blank?
      resource.errors.add(:current_password, "must be provided to update account.")
    else
      resource.update(params)
    end
  end

  def configure_devise_permitted_parameters
    registration_params = [:first_name, :last_name, :email, :username, :password, :password_confirmation, :current_password, :unencrypted_password]

    case params[:action]
    when 'update'
      devise_parameter_sanitizer.permit(:account_update) {
        |u| u.permit(registration_params << :current_password)
      }
    when 'create'
      devise_parameter_sanitizer.permit(:sign_up) {
        |u| u.permit(registration_params)
      }
    when 'delete'
      devise_parameter_sanitizer.permit(:delete) {
        |u| u.permit(registration_params)
      }
    end
  end

  def notify_user_of_email_confirmation
    respond_to do |format|
      format.html { redirect_to new_user_registration_path, notice: 'You will soon receive an email from AACT. Once you verify your information by responding to this email, a database account will be created for you.' }
    end
  end

end
