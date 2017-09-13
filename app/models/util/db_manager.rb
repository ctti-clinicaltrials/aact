module Util
  class DbManager

    def self.public_db_name
      'aact'
    end

    def self.change_password(user,pwd)
      begin
        con=ActiveRecord::Base.establish_connection(:public).connection
        con.execute("alter user #{user.username} password '#{pwd}'")
        con.disconnect!
      rescue => e
        user.errors.add(:base, e.message)
      end
    end

    def self.add_user(user)
      begin
        con=ActiveRecord::Base.establish_connection(:public).connection
        con.execute("create user #{user.username} password '#{user.unencrypted_password}'")
        con.execute("grant connect on database aact to #{user.username}")
        con.execute("grant usage on schema public TO #{user.username}")
        con.execute("grant select on all tables in schema public to #{user.username};")
        con.disconnect!
      rescue => e
        user.errors.add(:base, e.message)
      end
    end

    def self.remove_user(user)
      self.terminate_sessions_for(user)
      con=ActiveRecord::Base.establish_connection(:public).connection
      begin
      con.execute("drop owned by #{user.username};")
      con.execute("revoke all on schema public from #{user.username};")
      con.execute("drop user #{user.username};")
      rescue => e
        con.disconnect!
        raise e unless e.message == "role \"#{user.username}\" does not exist"
      end
      con.disconnect!
    end

    def self.grant_db_privs
      self.revoke_db_privs # to avoid errors, ensure privs revoked first
      con=ActiveRecord::Base.establish_connection(:public).connection
      con.execute("grant connect on database #{public_db_name} to public;")
      con.execute("grant usage on schema public TO public;")
      con.execute('grant select on all tables in schema public to public;')
      con.disconnect!
    end

    def self.revoke_db_privs
      self.terminate_active_sessions
      con=ActiveRecord::Base.establish_connection(:public).connection
      con.execute("revoke connect on database #{public_db_name} from public;")
      con.execute("revoke select on all tables in schema public from public;")
      con.execute("revoke all on schema public from public;")
      con.disconnect!
    end

    def self.terminate_sessions_for(user)
      con=ActiveRecord::Base.establish_connection(:public).connection
      con.select_all("select * from pg_stat_activity order by pid;").each { |session|
        if session['usename']=="#{user.username}"
          con.execute("select pg_terminate_backend(#{session['pid']})")
        end
      }
    end

    def self.terminate_active_sessions
      con=ActiveRecord::Base.establish_connection(:public).connection
      con.select_all("select * from pg_stat_activity order by pid;").each { |session|
        if session['datname']=="#{public_db_name}"
          con.execute("select pg_terminate_backend(#{session['pid']})")
        end
      }
      con.disconnect!
    end

  end

end
