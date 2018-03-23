require 'open3'
module Util
  class DbManager

    attr_accessor :con, :stage_con, :pub_con, :load_event

    def initialize(params={})
      if params[:load_event]
        @load_event = params[:load_event]
      else
        @load_event = Admin::LoadEvent.create({:event_type=>'ad hoc',:status=>'running',:description=>'',:problems=>''})
      end
    end

    def save_static_copy
      begin
        fm=Util::FileManager.new
        schema_diagram_file=File.open("#{fm.backend_schema_diagram}")
        admin_schema_diagram_file=File.open("#{fm.backend_admin_schema_diagram}")
        data_dictionary_file=File.open("#{fm.backend_data_dictionary}")
        nlm_protocol_file=fm.make_file_from_website("nlm_protocol_definitions.html",fm.nlm_protocol_data_url)
        nlm_results_file=fm.make_file_from_website("nlm_results_definitions.html",fm.nlm_results_data_url)

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
      rescue => error
        load_event.add_problem("#{error.message} (#{error.class} #{error.backtrace}")
      end
      return zip_file_name
    end

    def dump_database
      begin
        # First populate db named 'aact' from background db so the dump file will be configured to restore db named aact
        psql_file="#{Util::FileManager.dump_directory}/aact.psql"
        File.delete(psql_file) if File.exist?(psql_file)
        terminate_background_db_sessions
        cmd="pg_dump --no-owner --no-acl -h localhost -U #{ENV['DB_SUPER_USERNAME']} --exclude-table schema_migrations aact_back > #{psql_file}"
        run_command_line(cmd)

        # clear out previous content of staging db
        puts "Recreating public schema in aact staging database..."
        terminate_db_sessions
        stage_con.execute('DROP SCHEMA IF EXISTS public CASCADE')
        stage_con.execute('CREATE SCHEMA public')

        # refresh staging db
        puts "Refreshing aact staging database..."
        cmd="psql -h localhost aact < #{psql_file} > /dev/null"
        terminate_db_sessions
        run_command_line(cmd)

        fm=Util::FileManager.new
        db_name=ActiveRecord::Base.connection.current_database
        File.delete(fm.pg_dump_file) if File.exist?(fm.pg_dump_file)
        cmd="pg_dump aact -v -h localhost -p 5432 -U #{ENV['DB_SUPER_USERNAME']} --no-password --clean --exclude-table schema_migrations  -c -C -Fc -f  #{fm.pg_dump_file}"
        terminate_db_sessions
        run_command_line(cmd)
      rescue => error
        load_event.add_problem("#{error.message} (#{error.class} #{error.backtrace}")
      end
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
        load_event.add_problem("#{error.message} (#{error.class} #{error.backtrace}")
        grant_db_privs
        return false
      end
    end

    def grant_db_privs
      revoke_db_privs # to avoid errors, ensure privs revoked first
      pub_con.execute("grant connect on database #{public_db_name} to public;")
      pub_con.execute("grant usage on schema public TO public;")
      pub_con.execute('grant select on all tables in schema public to public;')
    end

    def revoke_db_privs
      pub_con.execute("revoke connect on database #{public_db_name} from public;")
      pub_con.execute("revoke select on all tables in schema public from public;")
      pub_con.execute("revoke all on schema public from public;")
    end

    def run_command_line(cmd)
      puts cmd
      stdout, stderr, status = Open3.capture3(cmd)
      if status.exitstatus != 0
        load_event.add_problem("#{stderr}")
        success_code=false
      end
    end

    def terminate_db_sessions
      pub_con.execute("SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE pid <> pg_backend_pid() AND datname = '#{public_db_name}'")
    end

    def terminate_alt_db_sessions
      pub_con.execute("SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE pid <> pg_backend_pid() AND datname = 'aact_alt'")
    end

    def terminate_background_db_sessions
      con.execute("SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE pid <> pg_backend_pid() AND datname = 'aact_back'")
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
