class User < AdminBase
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  def admin?
    false
  end

  def add
    con=ActiveRecord::Base.establish_connection(:public).connection
    con.execute("create user #{db_username}")
    con.execute("grant connect on database aact to #{db_username}")
    con.execute("grant usage on schema public TO #{db_username}")
    con.execute("grant select on all tables in schema public to #{db_username};")
  end

  def remove
    con=ActiveRecord::Base.establish_connection(:public).connection
    con.execute("drop owned by #{db_username};")
    con.execute("revoke all on schema public from #{db_username};")
    con.execute("drop user #{db_username};")
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
