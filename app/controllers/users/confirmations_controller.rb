class Users::ConfirmationsController < Devise::ConfirmationsController

  def show
    user=User.where('confirmation_token=?',params['confirmation_token']).first
    user.confirm
    redirect_to new_user_session_url
  end

  private

  def after_confirmation_path_for(resource_name, resource)
    redirect_to new_user_session_url
  end

end
