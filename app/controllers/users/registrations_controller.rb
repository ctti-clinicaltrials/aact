class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_devise_permitted_parameters, if: :devise_controller?

  def create
    super
    if resource.errors.size == 0
      Notifier.report_user_event('created', resource)
      flash[:notice] = 'You will soon receive an email from AACT. When you verify your email, you will have acces to your database account.'
    end
  end

  def destroy
    current_user.remove
    Notifier.report_user_event('removed', resource)
    redirect_to root_path
  end

  protected

  def update_resource(resource, params)
    resource.update(params)
    Notifier.report_user_event('updated', resource)
  end

  def configure_devise_permitted_parameters
    registration_params = [:first_name, :last_name, :email, :username, :password, :password_confirmation ]

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
