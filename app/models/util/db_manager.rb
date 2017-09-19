module Util
  class DbManager
    attr_accessor :con

    def self.add_user(user)
      new.add_user(user)
    end

    def self.remove_user(user)
      new.remove_user(user)
    end

    def self.change_password(user,pwd)
      new.change_password(user,pwd)
    end

    def self.grant_db_privs
      new.grant_db_privs
    end

    def self.revoke_db_privs
      new.revoke_db_privs
    end

    def self.can_add_user?(user)
      new.can_add_user?(user)
    end

    # =============== instance methods

    def can_add_user?(user)
      username=ActiveRecord::Base::sanitize(user.username.try(:downcase))
      res=con.execute("SELECT * FROM pg_catalog.pg_user where lower(usename) = #{username}").count == 0
      clean_up
      res
    end

    def add_user(user)
      begin
        con.execute("create user #{user.username} password '#{user.unencrypted_password}'")
        con.execute("grant connect on database aact to #{user.username}")
        con.execute("grant usage on schema public TO #{user.username}")
        con.execute("grant select on all tables in schema public to #{user.username};")
      rescue => e
        user.errors.add(:base, e.message)
      end
      clean_up
    end

    def remove_user(user)
      begin
        con.execute("drop owned by #{user.username};")
        con.execute("revoke all on schema public from #{user.username};")
        con.execute("drop user #{user.username};")
      rescue => e
        clean_up
        raise e unless e.message == "role \"#{user.username}\" does not exist"
      end
    end

    def change_password(user,pwd)
      begin
        con.execute("alter user #{user.username} password '#{pwd}'")
      rescue => e
        user.errors.add(:base, e.message)
      end
      clean_up
    end

    def grant_db_privs
      revoke_db_privs # to avoid errors, ensure privs revoked first
      con.execute("grant connect on database #{public_db_name} to public;")
      con.execute("grant usage on schema public TO public;")
      con.execute('grant select on all tables in schema public to public;')
      clean_up
    end

    def revoke_db_privs
      con.execute("revoke connect on database #{public_db_name} from public;")
      con.execute("revoke select on all tables in schema public from public;")
      con.execute("revoke all on schema public from public;")
      clean_up
    end

    def terminate_sessions_for(user)
      con.select_all("select * from pg_stat_activity order by pid;").each { |session|
        if session['usename']=="#{user.username}"
          con.execute("select pg_terminate_backend(#{session['pid']})")
        end
      }
      clean_up
    end

    def terminate_active_sessions
      con.select_all("select * from pg_stat_activity order by pid;").each { |session|
        if session['datname']=="#{public_db_name}"
          con.execute("select pg_terminate_backend(#{session['pid']})")
        end
      }
      clean_up
    end

    def clean_up
      con.disconnect!
      ActiveRecord::Base.establish_connection(Rails.env.to_sym).connection
    end

    def con
      @con ||= ActiveRecord::Base.establish_connection(:public).connection
    end

    def public_db_name
      'aact'
    end

  end

end
