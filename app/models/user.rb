class User < AdminBase
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  def admin?
    false
  end

  def add
    Util::DbManager.add_user(self)
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
