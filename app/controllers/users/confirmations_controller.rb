class Users::ConfirmationsController < Devise::ConfirmationsController

  def show
    user=User.where('confirmation_token=?',params['confirmation_token']).first
    if user
      user.confirm
      UserMailer.report_user_event('confirmed', user)
      flash[:notice] = "Your account has been confirmed. You now have access to the AACT database with the username #{user.username} and password you provided."
      sign_in(:user, user)
      redirect_to new_user_session_url
    else
      flash[:notice] = "Invalid confirmation token: #{params['confirmation_token']}."
      redirect_to new_user_session_url
    end
  end

end
