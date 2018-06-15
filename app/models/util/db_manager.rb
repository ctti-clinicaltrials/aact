require 'open3'
module Util
  class DbManager

    attr_accessor :con, :stage_con, :pub_con, :event

    def initialize(params={})
      if params[:event]
        @event = params[:event]
      else
        @event = Admin::LoadEvent.create({:event_type=>'',:status=>'',:description=>'',:problems=>''})
      end
    end

    def dump_database
      fm=Util::FileManager.new
      # First populate db named 'aact' from background db so the dump file will be configured to restore db named aact
      psql_file="#{fm.dump_directory}/aact.psql"
      File.delete(psql_file) if File.exist?(psql_file)
      # pg_dump that works on postgres 10.3
      #cmd="pg_dump --no-owner --no-acl --host=localhost --username=#{ENV['DB_SUPER_USERNAME']} --dbname=aact_back --schema=ctgov > #{psql_file}"
      # pg_dump that works on postgres 9.2.23 - which is what's running on servers as of 4/20/18
      cmd="pg_dump --no-owner --no-acl --host=localhost --username=#{ENV['DB_SUPER_USERNAME']} --schema=ctgov  aact_back > #{psql_file}"
      run_command_line(cmd)

      # clear out previous ctgov content from staging db
      log "recreating ctgov schema in aact staging database..."
      terminate_stage_db_sessions
      begin
        stage_con.execute('DROP SCHEMA ctgov CASCADE;')
      rescue
      end
      #stage_con.execute('CREATE SCHEMA ctgov;')

      # refresh staging db
      log "refreshing aact staging database..."
      cmd="psql -h localhost aact < #{psql_file} > /dev/null"
      run_command_line(cmd)

      File.delete(fm.pg_dump_file) if File.exist?(fm.pg_dump_file)
      cmd="pg_dump aact -v -h localhost -p 5432 -U #{ENV['DB_SUPER_USERNAME']} --no-password --clean --exclude-table schema_migrations --schema=ctgov -c -C -Fc -f  #{fm.pg_dump_file}"
      run_command_line(cmd)
      ActiveRecord::Base.establish_connection(ENV["AACT_BACK_DATABASE_URL"]).connection
    end

    def refresh_public_db
      begin
        success_code=true
        revoke_db_privs
        terminate_db_sessions
        dump_file_name=Util::FileManager.new.pg_dump_file
        return nil if dump_file_name.nil?
        cmd="pg_restore -c -j 5 -v -h #{public_host_name} -p 5432 -U #{ENV['DB_SUPER_USERNAME']}  -d #{public_db_name} #{dump_file_name}"
        run_command_line(cmd)

        terminate_alt_db_sessions
        cmd="pg_restore -c -j 5 -v -h #{public_host_name} -p 5432 -U #{ENV['DB_SUPER_USERNAME']}  -d aact_alt #{dump_file_name}"
        run_command_line(cmd)

        grant_db_privs
        return success_code
      rescue => error
        msg="#{error.message} (#{error.class} #{error.backtrace}"
        event.add_problem(msg)
        log msg
        grant_db_privs
        return false
      end
    end

    def grant_db_privs
      revoke_db_privs # to avoid errors, ensure privs revoked first
      c = PublicBase.establish_connection(ENV["AACT_PUBLIC_DATABASE_URL"]).connection
      c.execute("grant connect on database #{public_db_name} to public;")
      c.execute("grant usage on schema ctgov TO public;")
      c.execute('grant select on all tables in schema ctgov to public;')
      c.disconnect!
      c=nil
    end

    def revoke_db_privs
      log "db_manager.revoking db privs..."
      begin
        pub_con.execute("revoke connect on database #{public_db_name} from public;")
        pub_con.execute("revoke select on all tables in schema ctgov from public;")
        pub_con.execute("revoke all on schema ctgov from public;")
      rescue => error
        # error raised if schema missing. Ignore. Will be created in a pg_restore.
        log "db_manager.revoke_db_privs - error encountered:  #{error}"
      end
    end

    def public_db_accessible?
      result=pub_con.execute("select count(*) from information_schema.role_table_grants where grantee='PUBLIC' and table_schema='ctgov';").first["count"]
      result.to_i > 0
    end

    def run_command_line(cmd)
      stdout, stderr, status = Open3.capture3(cmd)
      if status.exitstatus != 0
        event.add_problem("#{Time.zone.now}: #{stderr}")
        success_code=false
      end
    end

    def log(msg)
      puts "#{Time.zone.now}: #{msg}"  # log to STDOUT
    end

    def terminate_stage_db_sessions
      stage_con.execute("SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE pid <> pg_backend_pid() AND datname ='aact'")
    end

    def terminate_db_sessions
      pub_con.execute("SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE pid <> pg_backend_pid() AND datname = '#{public_db_name}'")
    end

    def terminate_alt_db_sessions
      pub_con.execute("SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE pid <> pg_backend_pid() AND datname = 'aact_alt'")
    end

    def public_study_count
      pub_con.execute("select count(*) from studies").values.flatten.first.to_i
    end

    def background_study_count
      con.execute("select count(*) from studies").values.flatten.first.to_i
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
