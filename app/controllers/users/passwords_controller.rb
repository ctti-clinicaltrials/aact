class Users::PasswordsController < Devise::PasswordsController
  skip_before_filter :require_no_authentication, :only => [:edit, :update]
  prepend_before_action :require_no_authentication
  before_action :configure_devise_permitted_parameters

  def new
    self.resource = resource_class.new
  end

  def update
    self.resource = resource_class.reset_password_by_token(params[resource_name])
    yield resource if block_given?

    if resource and resource.errors.empty?
      sign_out(resource_name)
      sign_in(resource_name, resource)
    end
  end

  protected

  def save_password
    params[:user][:unencrypted_password]=params[:user][:password] if params[:user][:password] and !params[:user][:reset_password_token].blank?
  end

  def configure_devise_permitted_parameters
    params.permit :reset_password_token, :utf8, :_method, :authenticity_token, :commit, user: [:email, :reset_password_token, :password, :password_confirmation, :unencrypted_password]
  end

end

