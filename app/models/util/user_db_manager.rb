module Util
  class UserDbManager < DbManager

    def self.change_password(user, pwd)
      new.change_password(user, pwd)
    end

    def create_user_account(user)
      begin
        return false if !can_create_user_account?(user)
        #user.skip_password_validation=true  # don't validate that user entered current password.  already validated
        #pub_con = PublicBase.establish_connection(ENV["AACT_PUBLIC_DATABASE_URL"]).connection
        pub_con.execute("create user \"#{user.username}\" password '#{user.password}';")
        pub_con.execute("revoke connect on database aact from #{user.username};")
        #pub_con.disconnect!
        #@pub_con=nil
        return true
      rescue => e
        user.errors.add(:base, e.message)
        return false
      end
    end

    def can_create_user_account?(user)
      if user_account_exists?(user.username)
        user.errors.add(:Username, "Database account already exists for username '#{user.username}'")
        return false
      else
        return true
      end
    end

    def user_account_exists?(username)
      res=pub_con.execute("SELECT * FROM pg_catalog.pg_user where usename = '#{username}'").count > 0
    end

    def remove_user(username)
      begin
        return false if !user_account_exists?(username)
        revoke_db_privs(username)
        pub_con.execute("drop user #{username};")
        return true
      rescue => e
        raise e
      end
    end

    def change_password(user,pwd)
      puts "=========== about to set password to #{pwd} ===================================================="
      puts self.inspect
      puts "==============================================================="
      begin
        pub_con.execute("alter user \"#{user.username}\" password '#{pwd}';")
      rescue => e
        user.errors.add(:base, e.message)
      end
    end

    def grant_db_privs(username)
      pub_con.execute("grant connect on database aact to \"#{username}\";")
      pub_con.execute("grant usage on schema ctgov TO \"#{username}\";")
      pub_con.execute("grant select on all tables in schema ctgov to \"#{username}\";")
    end

    def revoke_db_privs(username)
      pub_con = PublicBase.establish_connection(ENV["AACT_PUBLIC_DATABASE_URL"]).connection
      pub_con.execute("reassign owned by #{username} to postgres;")
      pub_con.execute("drop owned by #{username};")
      pub_con.execute("revoke all on schema ctgov from #{username};")
      pub_con.execute("revoke connect on database #{public_db_name} from #{username};")
      pub_con.disconnect!
      @pub_con=nil
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
