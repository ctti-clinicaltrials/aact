require 'open3'
module Util
  class DbManager

    attr_accessor :con, :pub_con, :alt_pub_con, :event

    def initialize(params={})
      # Should only manage content of ctgov db schema
      if params[:event]
        @event = params[:event]
      else
        @event = Support::LoadEvent.create({:event_type=>'',:status=>'',:description=>'',:problems=>''})
      end
    end

    def dump_database
      fm=Util::FileManager.new
      File.delete(fm.pg_dump_file) if File.exist?(fm.pg_dump_file)

      cmd="pg_dump #{ENV['AACT_BACK_DATABASE_URL']} -v -h localhost -p 5432 -U #{ENV['AACT_DB_SUPER_USERNAME']} --clean --exclude-table ar_internal_metadata --exclude-table schema_migrations --schema ctgov -b -c -C -Fc -f #{fm.pg_dump_file}"
      run_command_line(cmd)
    end

   def refresh_public_db
      dump_file_name=Util::FileManager.new.pg_dump_file
      return nil if dump_file_name.nil?
      begin
        success_code=true
        revoke_db_privs   # Prevent users from logging in while db restore is running.

        # Refresh the aact_alt database first.  If something goes wrong, don't restore aact.
        drop_project_views(PublicBase.establish_connection(ENV["AACT_ALT_PUBLIC_DATABASE_URL"]).connection)
        terminate_alt_db_sessions

        begin
          #  Drop the existing ctgov schema with cascade. If dependencies exist on anything in ctgov, the restore won't be able to
          #  drop before replacing - resulting in a db of duplicate data.  Get rid of it using CASCADE' first.
          log "Dropping ctgov schema in alt public database..."
          cmd="DROP SCHEMA ctgov CASCADE;"
          PublicBase.establish_connection(ENV["AACT_ALT_PUBLIC_DATABASE_URL"]).connection.execute(cmd)
          cmd="CREATE SCHEMA ctgov;"
          PublicBase.establish_connection(ENV["AACT_ALT_PUBLIC_DATABASE_URL"]).connection.execute(cmd)
        rescue
        end
        log "Restoring alt public database..."
        cmd="pg_restore -c -j 5 -v -h #{public_host_name} -p 5432 -U #{ENV['AACT_DB_SUPER_USERNAME']}  -d aact_alt #{dump_file_name}"
        run_restore_command_line(cmd)

        log "Verifying alt public database..."
        public_studies_count = PublicBase.establish_connection(ENV["AACT_ALT_PUBLIC_DATABASE_URL"]).connection.execute('select count(*) from studies;').first['count'].to_i

        back_studies_count   = PublicBase.establish_connection(ENV["AACT_BACK_DATABASE_URL"]).connection.execute('select count(*) from studies;').first['count'].to_i
        if public_studies_count != back_studies_count
          success_code = false
          msg = "SOMETHING WENT WRONG!  PROBLEM IN PRODUCTION DATABASE: aact_alt.  Study count is #{public_studies_count}. Should be #{back_studies_count}"
          event.add_problem(msg)
          log msg
          grant_db_privs
          return false
        end
        create_project_views(PublicBase.establish_connection(ENV["AACT_ALT_PUBLIC_DATABASE_URL"]).connection)
        log "all systems go....  update public aact...."

        # If all goes well with AACT_ALT DB, proceed with AACT

        drop_project_views(PublicBase.establish_connection(ENV["AACT_PUBLIC_DATABASE_URL"]).connection)
        terminate_db_sessions
        begin
          log "Dropping ctgov schema in main public database..."
          cmd="DROP SCHEMA ctgov CASCADE;"
          PublicBase.establish_connection(ENV["AACT_PUBLIC_DATABASE_URL"]).connection.execute(cmd)
          cmd="CREATE SCHEMA ctgov;"
          PublicBase.establish_connection(ENV["AACT_PUBLIC_DATABASE_URL"]).connection.execute(cmd)
        rescue
        end
        log "Restoring main public database..."
        cmd="pg_restore -c -j 5 -v -h #{public_host_name} -p 5432 -U #{ENV['AACT_DB_SUPER_USERNAME']}  -d #{public_db_name} #{dump_file_name}"
        run_restore_command_line(cmd)
        create_project_views(PublicBase.establish_connection(ENV["AACT_PUBLIC_DATABASE_URL"]).connection)
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
      #pub_con.execute("alter user read_only login;")
      log "db_manager.granting db privs..."
      c = PublicBase.establish_connection(ENV["AACT_PUBLIC_DATABASE_URL"]).connection
      c.execute("grant connect on database #{public_db_name} to public;")
      c.execute("grant usage on schema ctgov TO public;")
      c.execute('grant select on all tables in schema ctgov to public;')
      c.reset!
      c=nil
    end

    def revoke_db_privs
      log "db_manager.revoking db privs..."
      begin
        #pub_con.execute("alter user read_only nologin;")
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

    def run_restore_command_line(cmd)
      stdout, stderr, status = Open3.capture3(cmd)
      if status.exitstatus != 0
          # Errors that report a db object doesn't already exist aren't real errors. Ignore those.  Look for real errors.
          real_errors = []
          stderr_array = stderr.split('pg_restore:')
          stderr_array.each {|line| real_errors << line  if line.include?('ERROR') && !line.include?("does not exist") }
          if !real_errors.empty?
            real_errors.each {|e| event.add_problem("#{Time.zone.now}: #{e}") }
            success_code=false
          end
        end
    end


    def log(msg)
      puts "#{Time.zone.now}: #{msg}"  # log to STDOUT
    end

    def terminate_db_sessions
      PublicBase.establish_connection(ENV["AACT_PUBLIC_DATABASE_URL"]).connection.execute("SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE pid <> pg_backend_pid() AND datname = '#{public_db_name}' AND usename <> '#{ENV['AACT_DB_SUPER_USERNAME']}'")
    end

    def terminate_alt_db_sessions
      PublicBase.establish_connection(ENV["AACT_ALT_PUBLIC_DATABASE_URL"]).connection.execute("SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE pid <> pg_backend_pid() AND datname = 'aact_alt' AND usename <> '#{ENV['AACT_DB_SUPER_USERNAME']}'")
    end

    def public_study_count
      begin
        pub_con.execute("select count(*) from studies").values.flatten.first.to_i
      rescue
        return 0
      end
    end

    def background_study_count
      Study.count
    end

    def remove_indexes
      m=ActiveRecord::Migration.new
      loadable_tables.each {|table_name|
        con.indexes(table_name).each{|index|
          m.remove_index(index.table, index.columns) if !should_keep_index?(index) and m.index_exists?(index.table, index.columns)
        }
      }
    end

    def add_indexes
      m=ActiveRecord::Migration.new
      indexes.each{|index| m.add_index index.first, index.last  if !m.index_exists?(index.first, index.last)}
      #  Add indexes for all the nct_id columns.  If error raised cuz nct_id doesn't exist for the table, skip it.
      ActiveRecord::Base.connection.tables.each{|table|
        begin
          m.add_index table, 'nct_id'
        rescue
        end
      }
    end

    def loadable_tables
      blacklist = %w(
        ar_internal_metadata
        schema_migrations
        data_definitions
        mesh_headings
        mesh_terms
        load_events
        mesh_terms
        mesh_headings
        sanity_checks
        statistics
        study_xml_records
        use_cases
        use_case_attachments
      )
      table_names=ActiveRecord::Base.connection.tables.reject{|table|blacklist.include?(table)}
    end

    def indexes
      [
         [:baseline_measurements, :dispersion_type],
         [:baseline_measurements, :param_type],
         [:baseline_measurements, :category],
         [:baseline_measurements, :classification],
         [:browse_conditions, :mesh_term],
         [:browse_conditions, :downcase_mesh_term],
         [:browse_interventions, :mesh_term],
         [:browse_interventions, :downcase_mesh_term],
         [:calculated_values, :actual_duration],
         [:calculated_values, :months_to_report_results],
         [:calculated_values, :number_of_facilities],
         [:central_contacts, :contact_type],
         [:conditions, :name],
         [:conditions, :downcase_name],
         [:design_groups, :group_type],
         [:design_outcomes, :outcome_type],
         [:designs, :masking],
         [:designs, :subject_masked],
         [:designs, :caregiver_masked],
         [:designs, :investigator_masked],
         [:designs, :outcomes_assessor_masked],
         [:documents, :document_id],
         [:documents, :document_type],
         [:drop_withdrawals, :period],
         [:eligibilities, :gender],
         [:eligibilities, :healthy_volunteers],
         [:eligibilities, :minimum_age],
         [:eligibilities, :maximum_age],
         [:facilities, :status],
         [:facility_contacts, :contact_type],
         [:facilities, :name],
         [:facilities, :city],
         [:facilities, :state],
         [:facilities, :country],
         [:id_information, :id_type],
         [:interventions, :intervention_type],
         [:keywords, :name],
         [:keywords, :downcase_name],
         [:mesh_terms, :qualifier],
         [:mesh_terms, :description],
         [:mesh_terms, :mesh_term],
         [:mesh_terms, :downcase_mesh_term],
         [:mesh_headings, :qualifier],
         [:milestones, :period],
         [:outcomes, :param_type],
         [:outcome_analyses, :dispersion_type],
         [:outcome_analyses, :param_type],
         [:outcome_measurements, :dispersion_type],
         [:outcomes, :dispersion_type],
         [:overall_officials, :affiliation],
         [:outcome_measurements, :category],
         [:outcome_measurements, :classification],
         [:reported_events, :event_type],
         [:reported_events, :subjects_affected],
         [:responsible_parties, :organization],
         [:responsible_parties, :responsible_party_type],
         [:result_contacts, :organization],
         [:result_groups, :result_type],
         [:sponsors, :agency_class],
         [:sponsors, :name],
         [:studies, :enrollment_type],
         [:studies, :overall_status],
         [:studies, :phase],
         [:studies, :last_known_status],
         [:studies, :primary_completion_date_type],
         [:studies, :source],
         [:studies, :study_type],
         [:studies, :study_first_submitted_date],
         [:studies, :results_first_submitted_date],
         [:studies, :disposition_first_submitted_date],
         [:studies, :last_update_submitted_date],
         [:studies, :results_first_submitted_qc_date],
         [:studies, :study_first_submitted_qc_date],
         [:studies, :last_update_submitted_qc_date],
         [:study_references, :reference_type],
      ]
    end

    def should_keep_index?(index)
      return true if index.table=='studies' and index.columns==['nct_id']
      return true if index.table=='study_xml_records' and index.columns==['nct_id']
      return true if index.table=='study_xml_records' and index.columns==['created_study_at']
      return true if index.table=='sanity_checks'
      false
    end

    def drop_project_views(conn)
      # Create a collection of 'DROP VIEW commands for each project view.
      creation_cmd="
        SELECT 'DROP VIEW ' || table_schema || '.' || table_name || ';'
          FROM information_schema.views
         WHERE table_schema LIKE 'proj_%'
           AND table_name != 'data_definitions';"
      cmds=conn.execute(creation_cmd)
      cmds.each{ |cmd|
        begin
          conn.execute(cmd['?column?'])
        rescue
          # Don't stop if error encountered while dropping view.  Prob cuz view doesn't exist yet.
        end
      }
    end

    def create_project_views(conn)
      Admin::Project.schema_name_array.each{|schema_name|
        if conn.execute("select nspname from pg_catalog.pg_namespace where nspname = '#{schema_name}';").count > 0
          schema_functions = conn.execute("SELECT routines.routine_name FROM information_schema.routines LEFT JOIN information_schema.parameters ON routines.specific_name=parameters.specific_name WHERE routines.specific_schema='#{schema_name}' ORDER BY routines.routine_name, parameters.ordinal_position;")
          create_view_function_exists = (schema_functions.select{|f| f['routine_name'] == 'create_views'}).size > 0
          cmd="select #{schema_name}.create_views();"
          if create_view_function_exists
            log "creating project view for #{schema_name}"
            conn.execute(cmd)
          end
        end
      }
    end

    def con
      return @con if @con and @con.active?
      @con = ActiveRecord::Base.establish_connection(ENV["AACT_BACK_DATABASE_URL"]).connection
      @con.schema_search_path='ctgov'
      return @con
    end

    def pub_con
      @pub_con ||= PublicBase.establish_connection(ENV["AACT_PUBLIC_DATABASE_URL"]).connection
    end

    def alt_pub_con
      @alt_pub_con ||= PublicBase.establish_connection(ENV["AACT_ALT_PUBLIC_DATABASE_URL"]).connection
    end

    def public_host_name
      ENV['AACT_PUBLIC_HOSTNAME']
    end

    def public_db_name
      ENV['AACT_PUBLIC_DATABASE_NAME']
    end

  end

end
