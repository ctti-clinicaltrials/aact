module Util
  class DbManager

    attr_accessor :con, :stage_con, :pub_con

    def self.create_user(user)
      new.create_user(user)
    end

    def self.create_unconfirmed_user(user)
      new.create_unconfirmed_user(user)
    end

    def self.change_password(user,pwd)
      new.change_password(user,pwd)
    end

    def self.can_create_user?(user)
      new.can_create_user?(user)
    end

    def create_unconfirmed_user(user)
      # We add the unconfirmed user to the db to reserve the username - prevent others from
      # subsequently trying to create user with same name before user confirms the account
      # When user eventually confirms the account, we will set their password to what they defined
      begin
        dummy_pwd=ENV['UNCONFIRMED_USER_PASSWORD']
        pub_con.execute("create user \"#{user.username}\" password '#{dummy_pwd}';")
        pub_con.execute("grant connect on database aact to \"#{user.username}\";")
        pub_con.execute("grant usage on schema public TO \"#{user.username}\";")
        pub_con.execute("grant select on all tables in schema public to \"#{user.username}\";")
      rescue => e
        user.errors.add(:base, e.message)
      end
    end

    def can_create_user?(user)
      !user_account_exists?(user)
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

    def take_snapshot
      dump_database
      fm=Util::FileManager.new
      schema_diagram_file=File.open("#{fm.static_root_dir}/documentation/aact_schema.png")
      admin_schema_diagram_file=File.open("#{fm.static_root_dir}/documentation/aact_admin_schema.png")
      data_dictionary_file=File.open("#{fm.static_root_dir}/documentation/aact_data_definitions.xlsx")
      nlm_protocol_file=fm.make_file_from_website('nlm_protocol_definitions.html',fm.nlm_protocol_data_url)
      nlm_results_file=fm.make_file_from_website('nlm_results_definitions.html',fm.nlm_results_data_url)

      zip_file_name="#{fm.class.static_copies_directory}/#{Time.now.strftime('%Y%m%d')}_clinical_trials.zip"
      File.delete(zip_file_name) if File.exist?(zip_file_name)
      Zip::File.open(zip_file_name, Zip::File::CREATE) {|zipfile|
        zipfile.add('schema_diagram.png',schema_diagram_file)
        zipfile.add('admin_schema_diagram.png',admin_schema_diagram_file)
        zipfile.add('data_dictionary.xlsx',data_dictionary_file)
        zipfile.add('postgres_data.dmp',fm.pg_dump_file)
        zipfile.add('nlm_protocol_definitions.html',nlm_protocol_file)
        zipfile.add('nlm_results_definitions.html',nlm_results_file)
      }
      return zip_file_name
    end

    def dump_database
      # First populate db named 'aact' from background db so the dump file will be configured to restore db named aact
      psql_file="#{Util::FileManager.dump_directory}/aact.psql"
      File.delete(psql_file) if File.exist?(psql_file)
      cmd="pg_dump --no-owner --no-acl aact_back > #{psql_file}"
      system cmd

      # clear out previous content of staging db
      stage_con.execute('DROP SCHEMA IF EXISTS public CASCADE')
      stage_con.execute('CREATE SCHEMA public')

      # refresh staging db
      cmd="psql aact < #{psql_file} > /dev/null"
      system cmd

      fm=Util::FileManager.new
      dump_file_name=fm.pg_dump_file
      db_name=ActiveRecord::Base.connection.current_database
      File.delete(dump_file_name) if File.exist?(dump_file_name)
      cmd="pg_dump aact -v -h localhost -p 5432 -U #{ENV['DB_SUPER_USERNAME']} --no-password --clean --exclude-table schema_migrations  -c -C -Fc -f  #{dump_file_name}"
      puts cmd
      system cmd
      return dump_file_name
    end

    def refresh_public_db
      revoke_db_privs
      dump_file_name=Util::FileManager.new.pg_dump_file
      return nil if dump_file_name.nil?
      cmd="pg_restore -c -j 5 -v -h #{public_host_name} -p 5432 -U #{ENV['DB_SUPER_USERNAME']}  -d #{public_db_name} #{dump_file_name}"
      system cmd
      cmd="pg_restore -c -j 5 -v -h #{public_host_name} -p 5432 -U #{ENV['DB_SUPER_USERNAME']}  -d aact_alt #{dump_file_name}"
      system cmd
      grant_db_privs
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
      @con ||= ActiveRecord::Base.establish_connection(ENV["AACT_BACK_DATABASE_URL"]).connection
    end

    def stage_con
      @stage_con ||= ActiveRecord::Base.establish_connection(ENV["AACT_STAGE_DATABASE_URL"]).connection
    end

    def pub_con
      @pub_con ||= PublicBase.establish_connection(ENV["AACT_PUBLIC_DATABASE_URL"]).connection
    end

    def public_host_name
      ENV['AACT_PUBLIC_HOSTNAME']
    end

    def public_db_name
      ENV['AACT_PUBLIC_DATABASE_NAME']
    end

  end

end
