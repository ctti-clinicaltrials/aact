class User < AdminBase
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  include ActiveModel::Validations
  attr_accessor :current_password, :skip_password_validation
  devise :confirmable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validates :current_password, presence: true, on: :update, unless: :skip_password_validation
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates_length_of :first_name, :maximum=>100
  validates_length_of :last_name, :maximum=>100
  validates :username, presence: true
  validates_uniqueness_of :username
  validates_length_of :username, :maximum=>64
  validates_format_of :username, :with => /\A[-_a-zA-Z0-9]+\z/, :message => "No special chars allowed"
  validates_format_of :username, :with => /\A[a-zA-Z]/, :message => "must start with alpha character"

  def admin?
    false
  end

  def confirm
    super
    self.skip_password_validation=true
    Util::DbManager.add_user(self)
    self.unencrypted_password=nil # after using this to create db account, get rid of it
    self.save!
  end

  def self.reset_password_by_token(params)
    original_token       = params[:reset_password_token]
    reset_password_token = Devise.token_generator.digest(self, :reset_password_token, original_token)
    resource=where('reset_password_token=?',reset_password_token).first
    if !resource.nil?
      resource.skip_password_validation=true
      resource.update_attributes({:password=>params[:password], :password_confirmation=>params[:password_confirmation]})
      Util::DbManager.change_password(resource,params[:password]) if resource.errors.empty?
    end
    resource
  end

  def update(params)
    params.delete(:password) if params[:password].blank?
    params.delete(:password_confirmation) if params[:password_confirmation].blank?
    update_attributes(params) if !skip_password_validation and valid_password?(params['current_password'])
    Util::DbManager.change_password(self,params[:password]) if params[:password]
    self
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

end
