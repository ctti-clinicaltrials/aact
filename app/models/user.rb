class User < Admin::AdminBase
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  include ActiveModel::Validations
  after_create { create_db_account }
  after_save :grant_db_privs, :if => proc { |l| l.confirmed_at_changed? && l.confirmed_at_was.nil? }
  attr_accessor :current_password, :skip_password_validation
  devise :confirmable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validates :current_password, presence: true, on: :update, unless: :skip_password_validation
  validates_confirmation_of :password
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates_length_of :first_name, :maximum=>100
  validates_length_of :last_name, :maximum=>100
  validates :username, presence: true
  validates_uniqueness_of :username
  validates_length_of :username, :minimum=>3
  validates_length_of :username, :maximum=>64
  validates_format_of :username, :with => /\A[a-zA-Z0-9]+\z/, :message => "cannot contain special chars"
  validates_format_of :username, :with => /\A[a-zA-Z]/, :message => "must start with an alpha character"
  validate :can_create_db_account?, :on => :create
  validate :can_access_db?, :on => :create

  def can_create_db_account?
    if Util::UserDbManager.new.user_account_exists?(self.username)
      self.errors.add(:Username, "Database account already exists for '#{self.username}'")
      return false
    else
      return true
    end
  end

  def can_access_db?
    if !Util::DbManager.new.public_db_accessible?
      self.errors.add(:Sorry, "AACT database is temporarily unavailable.  Please try later.")
      return false
    else
      return true
    end
  end

  def create_db_account
    event=Admin::UserEvent.create( { :event_type  => 'create', :email => self.email })
    mgr=Util::UserDbManager.new({ :event => event })
    if mgr.can_create_user_account?(self)
      mgr.create_user_account(self)
    else
      self.errors.add('DB Account', 'could not be created for this user.')
      event.description='Could not create this user.'
      event.save!
    end
  end

  def grant_db_privs
    event=Admin::UserEvent.create( { :email => self.email, :event_type => 'confirm' })
    Util::UserDbManager.new({ :event => event }).grant_db_privs(self.username)
  end

  def change_password(pwd)
    event=Admin::UserEvent.create( { :email=>self.email, :event_type=>'change-pwd' })
    db_mgr=Util::UserDbManager.new({:event => event})
    db_mgr.change_password(self, pwd)
  end

  def self.reset_password_by_token(params)
    original_token       = params[:reset_password_token]
    reset_password_token = Devise.token_generator.digest(self, :reset_password_token, original_token)
    user=where('reset_password_token=?',reset_password_token).first
    if !user.nil?
      user.skip_password_validation=true
      user.update_attributes({:password=>params[:password], :password_confirmation=>params[:password_confirmation]})
      user.change_password(params[:password]) if user.errors.empty?
      event=Admin::UserEvent.create( { :email=>user.email, :event_type=>'reset-pwd' })
    end
    user
  end

  def update(params)

    params.delete(:password) if params[:password].blank?
    params.delete(:password_confirmation) if params[:password_confirmation].blank?

    can_access_db?

    if !valid_password?(params['current_password'])
      self.errors.add(:current_password, "is invalid.")
      return false
    end

    self.errors.add(:current_password, "must be provided to update account.") if params[:current_password].blank?
    self.errors.add(:password_confirmation, "& Password must be provided to change your password.") if !params[:password].blank? && params[:password_confirmation].blank?
    self.errors.add(:password, "& Confirmation Password must be provided to change your password.") if !params[:password_confirmation].blank? && params[:password].blank?
    return false if !self.errors.empty?

    update_successful=super

    if update_successful
      event=Admin::UserEvent.create( { :email => self.email, :event_type =>'update' })
      db_mgr=Util::UserDbManager.new({ :event => event })
      db_mgr.change_password(self, params[:password]) if params[:password]
      self
    end
  end

  def remove
    begin
      return false if !can_access_db?
      Admin::RemovedUser.create(self.attributes.except('id', 'created_at', 'updated_at'))
      event=Admin::UserEvent.create( { :email => self.email, :event_type =>'remove' })

      db_mgr=Util::UserDbManager.new({ :event=> event })
      db_mgr.pub_con.execute("SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE usename = '#{self.username}'")
      db_mgr.remove_user(self.username)
      destroy
    rescue => e
      self.errors.add(e.message)
      puts e.message
    end
  end

  def full_name
    first_name + ' ' + last_name
  end

  def display_confirmed_at
    return '' if self.confirmed_at.nil?
    self.confirmed_at.strftime('%Y/%m/%d')
  end

  def display_confirmation_sent_at
    return '' if self.confirmation_sent_at.nil?
    self.confirmation_sent_at.strftime('%Y/%m/%d')
  end

  def display_last_sign_in_at
    return '' if self.last_sign_in_at.nil?
    self.last_sign_in_at.strftime('%Y/%m/%d')
  end

  def summary_info(type=nil)
    if type == 'list'
      "#{id}|#{self.full_name}|#{self.username}|#{self.email}|#{self.confirmation_sent_at.try(:strftime,"%m/%d/%Y %H:%m")}|#{self.confirmed_at.try(:strftime,"%m/%d/%Y %H:%m")}|#{self.sign_in_count}|#{self.last_sign_in_at.try(:strftime,"%m/%d/%Y %H:%m")}|#{self.last_sign_in_ip}"
    else
      "ID:  #{id}
       Name:  #{self.full_name}
       DB username:  #{self.username}
       Email addr:  #{self.email}

       Confirmation email sent: #{self.confirmation_sent_at.try(:strftime,"%m/%d/%Y %H:%m")}
       Confirmed: #{self.confirmed_at.try(:strftime,"%m/%d/%Y %H:%m")}

       Sign in count: #{self.sign_in_count}
       Last signed in: #{self.last_sign_in_at.try(:strftime,"%m/%d/%Y %H:%m")}  (#{self.last_sign_in_ip})
      "
    end
  end

  def notification_subject_line(event_type)
    "AACT #{Rails.env.capitalize} user #{event_type}: #{self.full_name}"
  end

  def self.list
    collection=[]
    all.each{ |user| collection << user.summary_info('list') }
    return collection
  end

  def self.to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << column_names
      all.each do |user|
        csv << user.attributes.values_at(*column_names)
      end
    end
  end
end
