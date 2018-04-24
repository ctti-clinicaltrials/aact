class Users::ConfirmationsController < Devise::ConfirmationsController

  def show
    user=User.where('confirmation_token=?',params['confirmation_token']).first
    if user
      user.confirm
      flash[:notice] = "Your account has been confirmed. You now have access to the AACT database with the username #{user.username} and password you provided."
      redirect_to new_user_session_url
    else
      flash[:notice] = "Invalid confirmation token: #{params['confirmation_token']}."
      redirect_to new_user_session_url
    end
  end

  private

  def after_confirmation_path_for(resource_name, resource)
    redirect_to new_user_session_url
  end

end
