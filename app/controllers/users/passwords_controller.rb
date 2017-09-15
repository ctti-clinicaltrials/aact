class Users::PasswordsController < Devise::PasswordsController
  skip_before_filter :require_no_authentication, :only => [:edit, :update]
  before_action :configure_devise_permitted_parameters

  def new
    self.resource = resource_class.new
  end

  def update
    resource = resource_class.reset_password_by_token(params[resource_name])
    if resource
      yield resource if block_given?
      sign_out(:user)
      sign_in(:user, resource)
    end
    redirect_to root_path
  end

  protected

  def configure_devise_permitted_parameters
    params.permit :reset_password_token, :utf8, :_method, :authenticity_token, :commit, user: [:email, :reset_password_token, :password, :password_confirmation, :unencrypted_password]
  end

end

