module Util
  class UserDbManager < DbManager

    def self.change_password(user,pwd)
      new.change_password(user,pwd)
    end

    def create_user_account(user)
      # We add the unconfirmed user to the db to reserve the username - prevent others from
      # subsequently trying to create user with same name before user confirms the account
      # When user eventually confirms the account, we will set their password to what they defined
      begin
        if !can_create_user_account?(user)
          return false
        end
        user.skip_password_validation=true  # don't validate user entered current password - they didn't have a chance!
        user.unencrypted_password=user.password
        dummy_pwd=ENV['UNCONFIRMED_USER_PASSWORD']
        pub_con = PublicBase.establish_connection(ENV["AACT_PUBLIC_DATABASE_URL"]).connection

        pub_con.execute("create user \"#{user.username}\" password '#{dummy_pwd}';")
        pub_con.execute("grant connect on database aact to \"#{user.username}\";")
        pub_con.execute("grant usage on schema ctgov TO \"#{user.username}\";")
        pub_con.execute("grant select on all tables in schema ctgov to \"#{user.username}\";")
        pub_con.disconnect!
        @pub_con=nil
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
        pub_con.execute("reassign owned by #{username} to postgres;")
        pub_con.execute("drop owned by #{username};")
        pub_con.execute("revoke all on schema ctgov from #{username};")
        pub_con.execute("revoke connect on database #{public_db_name} from #{username};")
        pub_con.execute("drop user #{username};")
        return true
      rescue => e
        raise e unless e.message.include? " does not exist"
        return false
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
      con.execute("grant usage on schema ctgov TO public;")
      con.execute('grant select on all tables in schema ctgov to public;')
    end

    def revoke_db_privs
      con.execute("revoke connect on database #{public_db_name} from public;")
      con.execute("revoke select on all tables in schema ctgov from public;")
      con.execute("revoke all on schema ctgov from public;")
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
