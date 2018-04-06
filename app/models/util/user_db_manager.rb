module Util
class UserDbManager < DbManager

  def self.change_password(user,pwd)
    new.change_password(user,pwd)
  end

  def create_user_account(user)
    # We add the unconfirmed user to the db to reserve the username - prevent others from
    # subsequently trying to create user with same name before user confirms the account
    # When user eventually confirms the account, we will set their password to what they defined
    #begin
      return false if !can_create_user?(user)
      user.skip_password_validation=true  # don't validate user entered current password - they didn't have a chance!
      user.unencrypted_password=user.password
      user.save!
      dummy_pwd=ENV['UNCONFIRMED_USER_PASSWORD']
      pub_con = PublicBase.establish_connection(ENV["AACT_PUBLIC_DATABASE_URL"]).connection

      pub_con.execute("create user \"#{user.username}\" password '#{dummy_pwd}';")
      pub_con.execute("grant connect on database aact to \"#{user.username}\";")
      pub_con.execute("grant usage on schema public TO \"#{user.username}\";")
      pub_con.execute("grant select on all tables in schema public to \"#{user.username}\";")
    #rescue => e
    #  user.errors.add(:base, e.message)
    #end
  end

  def can_create_user?(user)
    if user_account_exists?(user)
      user.errors.add(:Username, "Database account already exists for username '#{user.username}'")
      return false
    else
      return true
    end
  end

  def user_account_exists?(user)
    res=pub_con.execute("SELECT * FROM pg_catalog.pg_user where usename = '#{user.username}'").count > 0
  end

  def create_user(user)
    begin
      pub_con.execute("create user \"#{user.username}\" password '#{user.unencrypted_password}'")
      pub_con.execute("grant connect on database aact to \"#{user.username}\"")
      pub_con.execute("grant usage on schema public TO \"#{user.username}\"")
      pub_con.execute("grant select on all tables in schema public to \"#{user.username}\";")
    rescue => e
      user.errors.add(:base, e.message)
    end
  end

  def remove_user(user)
    begin
      pub_con.execute("drop owned by \"#{user.username}\";")
      pub_con.execute("revoke all on schema public from \"#{user.username}\";")
      pub_con.execute("revoke connect on database #{public_db_name} from \"#{user.username}\";")
      pub_con.execute("drop user \"#{user.username}\";")
    rescue => e
      raise e unless e.message.include? " does not exist"
    end
  end

  def change_password(user,pwd)
    begin
      pub_con.execute("alter user \"#{user.username}\" password '#{pwd}';")
    rescue => e
      user.errors.add(:base, e.message)
    end
  end

  def grant_db_privs
    revoke_db_privs # to avoid errors, ensure privs revoked first
    con.execute("grant connect on database #{public_db_name} to public;")
    con.execute("grant usage on schema public TO public;")
    con.execute('grant select on all tables in schema public to public;')
  end

  def revoke_db_privs
    con.execute("revoke connect on database #{public_db_name} from public;")
    con.execute("revoke select on all tables in schema public from public;")
    con.execute("revoke all on schema public from public;")
  end

  def terminate_sessions_for(user)
    con.select_all("select * from pg_stat_activity order by pid;").each { |session|
      if session['usename']=="#{user.username}"
        con.execute("select pg_terminate_backend(#{session['pid']})")
      end
    }
  end
end
end
