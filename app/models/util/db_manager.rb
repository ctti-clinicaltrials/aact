module Util
  class DbManager

    attr_accessor :con

    def self.create_user(user)
      new.create_user(user)
    end

    def self.create_unconfirmed_user(user)
      new.create_unconfirmed_user(user)
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

    def self.can_create_user?(user)
      new.can_create_user?(user)
    end

    # =============== instance methods

    def create_unconfirmed_user(user)
      # We add the unconfirmed user to the db to reserve the username - prevent others from
      # subsequently trying to create user with same name before user confirms the account
      # When user eventually confirms the account, we will set their password to what they defined
      begin
        dummy_pwd=ENV['UNCONFIRMED_USER_PASSWORD']
        con.execute("create user \"#{user.username}\" password '#{dummy_pwd}';")
        con.execute("grant connect on database aact to \"#{user.username}\";")
        con.execute("grant usage on schema public TO \"#{user.username}\";")
        con.execute("grant select on all tables in schema public to \"#{user.username}\";")
      rescue => e
        user.errors.add(:base, e.message)
      end
    end

    def can_create_user?(user)
      !user_account_exists?(user)
    end

    def user_account_exists?(user)
      res=con.execute("SELECT * FROM pg_catalog.pg_user where usename = '#{user.username}'").count > 0
    end

    def create_user(user)
      begin
        con.execute("create user \"#{user.username}\" password '#{user.unencrypted_password}'")
        con.execute("grant connect on database aact to \"#{user.username}\"")
        con.execute("grant usage on schema public TO \"#{user.username}\"")
        con.execute("grant select on all tables in schema public to \"#{user.username}\";")
      rescue => e
        user.errors.add(:base, e.message)
      end
    end

    def remove_user(user)
      begin
        con.execute("drop owned by \"#{user.username}\";")
        con.execute("revoke all on schema public from \"#{user.username}\";")
        con.execute("revoke connect on database #{public_db_name} from \"#{user.username}\";")
        con.execute("drop user \"#{user.username}\";")
      rescue => e
        raise e unless e.message.include? "role \"#{user.username}\" does not exist"
      end
    end

    def change_password(user,pwd)
      begin
        con.execute("alter user \"#{user.username}\" password '#{pwd}';")
      rescue => e
        user.errors.add(:base, e.message)
      end
    end

    def refresh_public_db(static_file)
      dump_file=Util::FileManager.new.get_dump_file_from(static_file)
      return nil if dump_file.nil?
      cmd="pg_restore -c -j 5 -v -h localhost -p 5432 -U #{ENV['DB_SUPER_USERNAME']}  -d #{public_db_name} #{dump_file}"
      system cmd
      cmd="pg_restore -c -j 5 -v -h localhost -p 5432 -U #{ENV['DB_SUPER_USERNAME']}  -d aact_alt #{dump_file}"
      system cmd
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

    def terminate_active_sessions
      con.select_all("select * from pg_stat_activity order by pid;").each { |session|
        if session['datname']=="#{public_db_name}"
          con.execute("select pg_terminate_backend(#{session['pid']})")
        end
      }
    end

    def con
      @con ||= PublicBase.establish_connection(ENV["PUBLIC_DATABASE_URL"]).connection
    end

    def public_db_name
      'aact'
    end

  end

end
