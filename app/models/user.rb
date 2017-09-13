class User < AdminBase
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  attr_accessor :current_password, :skip_password_validation
  devise :confirmable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validates :current_password, presence: true, on: :update, unless: :skip_password_validation
  validates :first_name, presence: true, on: :update
  validates :last_name, presence: true, on: :update

  def admin?
    false
  end

  def create_db_account
    self.skip_password_validation=true
    Util::DbManager.add_user(self)
    self.unencrypted_password=nil # after using this to create db account, get rid of it
    self.save!
  end

  def update(params)
    params.delete(:password) if params[:password].blank?
    params.delete(:password_confirmation) if params[:password_confirmation].blank?
    update_attributes(params) if valid_password?(params['current_password'])
    Util::DbManager.change_password(self,params[:password]) if params[:password]
  end

  def remove
    Util::DbManager.remove_user(self)
    destroy
  end

  def self.remove(email)
    where('email=?',email).first.try(:remove)
  end

  def full_name
    first_name + ' ' + last_name
  end

  def db_username
    email.gsub(/[^a-z0-9 ]/i, '')
  end
end
