class UsersController < ApplicationController
  #before_action :authenticate_user, only: [:index, :show, :edit, :destroy]

  def index
    @user_count = User.all.size
    @users = User.all.sort_by &:last_name
  end

  def show
  end

  def edit
  end

  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to admin_url, notice: 'User was removed.' }
      format.json { head :no_content }
    end
  end

  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.fetch(:user, {})
      params.require(:user).permit(:utf8, :authenticity_token, :commit, :_method, :id, :first_name, :last_name, :email, :username, :pwd)
    end

    def authenticate_user
      if !params[:pwd] and !params['user']
        render plain: "Only editable by authorized folks."
      end
      if params[:pwd] and params[:pwd] != ENV["AACT_VIEW_PASSWORD"]
        render plain: "Only editable by authorized folks."
      end
      if params['user'] and (!params['user']['pwd'] or params['user']['pwd'] != ENV["AACT_VIEW_PASSWORD"])
        render plain: "Only editable by authorized folks."
      end
    end

end

