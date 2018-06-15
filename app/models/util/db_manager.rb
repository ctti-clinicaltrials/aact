require 'open3'
module Util
  class DbManager

    attr_accessor :con, :stage_con, :pub_con, :event

    def initialize(params={})
      # Should only manage content of ctgov db schema
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

    def con
      return @con if @con and @con.active?
      @con = ActiveRecord::Base.establish_connection(ENV["AACT_BACK_DATABASE_URL"]).connection
      @con.schema_search_path='ctgov'
      return @con
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
