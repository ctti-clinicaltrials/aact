class Users::ConfirmationsController < Devise::ConfirmationsController

  def show
    user=User.where('confirmation_token=?',params[:confirmation_token]).first
    user.confirm
    render 'pages/home'
  end

  private

  def after_confirmation_path_for(resource_name, resource)
    render 'pages/home'
  end

end
