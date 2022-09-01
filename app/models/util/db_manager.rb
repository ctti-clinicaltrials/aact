require 'open3'
module Util
  class DbManager

    attr_accessor :con, :public_con, :public_alt_con, :event, :migration_object, :fm

    def initialize(params={})
      # 'event' keeps track of what happened during a single load event & then saves to LoadEvent table in the admin db, so we have a log
      # of all load events that have occurred.  If an event is passed in, use it; otherwise, create a new one.
      if params[:event]
        @event = params[:event]
      else
        # @event = Support::LoadEvent.create({:event_type=>'',:status=>'',:description=>'',:problems=>''})
      end
      @fm = Util::FileManager.new

      # load configuration file
      @config = YAML.load(File.read("#{Rails.root}/config/connections.yml")).deep_symbolize_keys
      @search_path = params[:search_path] ? params[:search_path] : 'ctgov'
    end

    # generate a db dump file
    def dump_database
      dump_file_location = fm.pg_dump_file
      File.delete(dump_file_location) if File.exist?(dump_file_location)
      config = Study.connection.instance_variable_get('@config')
      host, port, username, database = config[:host], config[:port], config[:username], config[:database]
      host ||= 'localhost'
      port ||= 5432

      cmd = "
        pg_dump  -v -h #{host} -p #{port} -U #{username} \
        --clean --no-owner -b -c -C -Fc \
        --exclude-table ar_internal_metadata \
        --exclude-table schema_migrations \
        --schema 'ctgov'  \
        -f #{dump_file_location} \
        #{database} \
      "
      puts cmd
      run_command_line(cmd)

      return dump_file_location
    end

    # Restoring a database
    # 1. prevent new connections and disconnect current connections
    # 2. recreate the ctgov schema in the db
    # 3. restore teh db from file
    # 4. verify the study count (permissions are not granted again to prevent bad data from being used)
    # 5. grant connection permissions again
    def restore_database(schema, connection, filename)
      if schema =~ /beta/
        schema = 'ctgov_beta'
      elsif schema =~ /archive/
        schema = 'ctgov_archive'
      else
        schema = 'ctgov'
      end
      config = connection.instance_variable_get('@config')
      host, port, username, database, password = config[:host], config[:port], config[:username], config[:database], config[:password]

      # prevent new connections and drop current connections
      connection.execute("ALTER DATABASE #{database} CONNECTION LIMIT 0;")
      connection.execute("SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE pid <> pg_backend_pid() AND datname ='#{database}' AND usename <> '#{username}'")

      # drop the schema
      log "  dropping in #{host}:#{port}/#{database} database..."
      begin
        connection.execute("DROP SCHEMA #{schema} CASCADE;")
      rescue ActiveRecord::StatementInvalid => e
        log(e.message)
      end
      connection.execute("CREATE SCHEMA #{schema};")
      connection.execute("GRANT USAGE ON SCHEMA #{schema} TO read_only;")

      # restore database
      log "  restoring to #{host}:#{port}/#{database} database..."
      cmd = "PGPASSWORD=#{password} pg_restore -c -j 5 -v -h #{host} -p #{port} -U #{username}  -d #{database} #{filename}"
      run_restore_command_line(cmd)

      # verify that the database was correctly restored
      log "  verifying #{host}:#{port}/#{database} database..."
      study_count = connection.execute('select count(*) from studies;').first['count'].to_i
      if study_count != Study.count
        raise "SOMETHING WENT WRONG! PROBLEM IN PRODUCTION DATABASE: #{host}:#{port}/#{database}.  Study count is #{study_count}. Should be #{Study.count}"
      end

      # allow users to access database again
      connection.execute("ALTER DATABASE #{database} CONNECTION LIMIT 200;")
      connection.execute("GRANT USAGE ON SCHEMA #{schema} TO read_only;")
      connection.execute("GRANT SELECT ON ALL TABLES IN SCHEMA #{schema} TO READ_ONLY;")

      return true
    end

    # process for deploying database to digital ocean
    # 1. try restoring to staging db
    # 2. if successful restore to public db
    def refresh_public_db(schema='ctgov')
      success = restore_database(schema, staging_connection, fm.pg_dump_file)
      return unless success

      restore_database(schema, public_connection, fm.pg_dump_file)
    end


    def clear_out_data_for(nct_ids)
      ids=nct_ids.map { |i| "'" + i.to_s + "'" }.join(",")
      Util::DbManager.loadable_tables.each { |table|
        stime=Time.zone.now
        con.execute("DELETE FROM #{@search_path}.#{table} WHERE nct_id IN (#{ids})")
        log("deleted studies from #{@search_path}.#{table}   #{Time.zone.now - stime}")
      }
      delete_xml_records(ids) if @search_path == 'ctgov'
    end

    def delete_xml_records(ids)
      con.execute("DELETE FROM support.study_xml_records WHERE nct_id IN (#{ids})")
    end

    def public_study_count
      begin
        public_connection.execute('select count(*) from studies;').first['count'].to_i
      rescue
        return 0
      end
    end

    def revoke_db_privs
      log "  db_manager: set connection limit so only db owner can login..."
      public_con.execute("ALTER DATABASE #{db_name} CONNECTION LIMIT 0;")
      public_alt_con.execute("ALTER DATABASE #{alt_db_name} CONNECTION LIMIT 0;")
    end

    def grant_db_privs
      public_con.execute("ALTER DATABASE #{db_name} CONNECTION LIMIT 200;")
      public_con.execute("GRANT USAGE ON SCHEMA ctgov TO read_only;")
      public_con.execute("GRANT SELECT ON ALL TABLES IN SCHEMA CTGOV TO READ_ONLY;")
      public_alt_con.execute("ALTER DATABASE #{alt_db_name} CONNECTION LIMIT 200;")
      public_alt_con.execute("GRANT USAGE ON SCHEMA ctgov TO read_only;")
      public_alt_con.execute("GRANT SELECT ON ALL TABLES IN SCHEMA CTGOV TO READ_ONLY;")
    end

    def public_db_accessible?
      # we temporarily restrict access to the public db (set allowed connections to zero) during db restore.
      public_con.execute("select datconnlimit from pg_database where datname='#{db_name}';").first["datconnlimit"].to_i > 0
    end

    def run_command_line(cmd)
      stdout, stderr, status = Open3.capture3(cmd)
      if status.exitstatus != 0
        log stderr
        event.add_problem("#{Time.zone.now}: #{stderr}")
        success_code = false
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

    def terminate_db_sessions(db_name)
      public_con.execute("SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE pid <> pg_backend_pid() AND datname ='#{db_name}' AND usename <> '#{ENV['AACT_DB_SUPER_USERNAME']}'")
    end

    def add_indexes_and_constraints
      add_indexes
      add_constraints
    end

    def add_indexes
      indexes.each{|index| migration.add_index index.first, index.last  if !migration.index_exists?(index.first, index.last)}
      #  Add indexes for all the nct_id columns.  If error raised cuz nct_id doesn't exist for the table, skip it.
      Util::DbManager.loadable_tables.each {|table_name|
        begin
          if table_name != 'studies'  # studies.nct_id unique index persists.  Don't add/remove it.
            if one_to_one_related_tables.include? table_name
              migration.add_index table_name, 'nct_id', unique: true
            else
              migration.add_index table_name, 'nct_id'
            end
            #  foreign keys that link to the studies table via the nct_id
            if !con.foreign_keys(table_name).map(&:column).include?("nct_id")
              migration.add_foreign_key table_name,  "studies", column: "nct_id", primary_key: "nct_id", name: "#{table_name}_nct_id_fkey"
            end
          end
        rescue => e
          log(e)
          event.add_problem("#{Time.zone.now}: #{e}") if event
        end
      }
    end

    def add_constraints
      foreign_key_constraints.each { |constraint |
        child_table = constraint[:child_table]
        parent_table = constraint[:parent_table]
        child_column = constraint[:child_column]
        parent_column = constraint[:parent_column]
        begin
          migration.add_foreign_key child_table,  parent_table, column: child_column, primary_key: parent_column, name: "#{child_table}_#{child_column}_fkey"
        rescue => e
          log(e)
          event.add_problem("#{Time.zone.now}: #{e}") if event
        end
      }
    end

    def remove_indexes_and_constraints
      Util::DbManager.loadable_tables.each {|table_name|
        # remove foreign key that links most tables to Studies table via the NCT ID
        begin
          con.remove_foreign_key table_name, column: :nct_id if con.foreign_keys(table_name).map(&:column).include?("nct_id")
        rescue => e
          log(e)
          event.add_problem("#{Time.zone.now}: #{e}") if event
        end

        con.indexes(table_name).each{|index|
          begin
            migration.remove_index(index.table, index.columns) if !should_keep_index?(index) and migration.index_exists?(index.table, index.columns)
          rescue => e
            log(e)
            event.add_problem("#{Time.zone.now}: #{e}") if event
          end
        }
      }
      # Remove foreign Key constraints
      foreign_key_constraints.each { |constraint|
        table = constraint[:child_table]
        column = constraint[:child_column]
        begin
          con.remove_foreign_key table, column: column if con.foreign_keys(table).map(&:column).include?(column)
        rescue => e
          log(e)
          event.add_problem("#{Time.zone.now}: #{e}") if event
        end
      }
    end

    def remove_constraints
      Util::DbManager.loadable_tables.each {|table_name|
        # remove foreign key that links most tables to Studies table via the NCT ID
        begin
          con.remove_foreign_key table_name, column: :nct_id if con.foreign_keys(table_name).map(&:column).include?("nct_id")
        rescue => e
          log(e)
          event.add_problem("#{Time.zone.now}: #{e}") if event
        end
      }

      foreign_key_constraints.each { |constraint|
        table = constraint[:child_table]
        column = constraint[:child_column]
        begin
          con.remove_foreign_key table, column: column if con.foreign_keys(table).map(&:column).include?(column)
        rescue => e
          log(e)
          event.add_problem("#{Time.zone.now}: #{e}") if event
        end
      }
    end

    def self.loadable_tables
      blacklist = %w(
        active_storage_blobs
        active_storage_attachments
        ar_internal_metadata
        schema_migrations
        data_definitions
        mesh_headings
        mesh_terms
        load_events
        sanity_checks
        study_searches
        statistics
        study_xml_records
        study_json_records
        use_cases
        use_case_attachments
        verifiers
      )
      table_names=con.tables.reject{|table|blacklist.include?(table)}
    end

    def indexes
      # we drop all indexes to dramatically speed loads. This is used to recreate them after the load.  (better way?)
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
         [:design_outcomes, :measure],
         [:design_outcomes, :outcome_type],
         [:designs, :masking],
         [:designs, :subject_masked],
         [:designs, :caregiver_masked],
         [:designs, :investigator_masked],
         [:designs, :outcomes_assessor_masked],
         [:design_group_interventions, :design_group_id],
         [:design_group_interventions, :intervention_id],
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
         [:study_references, :pmid],
         [:study_references, :reference_type],
      ]
    end

    def foreign_key_constraints
      # we drop all constraints to dramatically speed loads. This is used to recreate them after the load.  (better way?)
      [
        {:child_table => 'baseline_counts',            :parent_table => 'result_groups',    :child_column => 'result_group_id',     :parent_column => 'id'},
        {:child_table => 'baseline_measurements',      :parent_table => 'result_groups',    :child_column => 'result_group_id',     :parent_column => 'id'},
        {:child_table => 'design_group_interventions', :parent_table => 'interventions',    :child_column => 'intervention_id',     :parent_column => 'id'},
        {:child_table => 'design_group_interventions', :parent_table => 'design_groups',    :child_column => 'design_group_id',     :parent_column => 'id'},
        {:child_table => 'drop_withdrawals',           :parent_table => 'result_groups',    :child_column => 'result_group_id',     :parent_column => 'id'},
        {:child_table => 'reported_events',            :parent_table => 'result_groups',    :child_column => 'result_group_id',     :parent_column => 'id'},
        {:child_table => 'facility_contacts',          :parent_table => 'facilities',       :child_column => 'facility_id',         :parent_column => 'id'},
        {:child_table => 'facility_investigators',     :parent_table => 'facilities',       :child_column => 'facility_id',         :parent_column => 'id'},
        {:child_table => 'intervention_other_names',   :parent_table => 'interventions',    :child_column => 'intervention_id',     :parent_column => 'id'},
        {:child_table => 'milestones',                 :parent_table => 'result_groups',    :child_column => 'result_group_id',     :parent_column => 'id'},
        {:child_table => 'outcome_analyses',           :parent_table => 'outcomes',         :child_column => 'outcome_id',          :parent_column => 'id'},
        {:child_table => 'outcome_analysis_groups',    :parent_table => 'result_groups',    :child_column => 'result_group_id',     :parent_column => 'id'},
        {:child_table => 'outcome_analysis_groups',    :parent_table => 'outcome_analyses', :child_column => 'outcome_analysis_id', :parent_column => 'id'},
        {:child_table => 'outcome_counts',             :parent_table => 'outcomes',         :child_column => 'outcome_id',          :parent_column => 'id'},
        {:child_table => 'outcome_counts',             :parent_table => 'result_groups',    :child_column => 'result_group_id',     :parent_column => 'id'},
        {:child_table => 'outcome_measurements',       :parent_table => 'outcomes',         :child_column => 'outcome_id',          :parent_column => 'id'},
        {:child_table => 'outcome_measurements',       :parent_table => 'result_groups',    :child_column => 'result_group_id',     :parent_column => 'id'},
      ]
    end


    def schema_image
      models = Util::DbManager.loadable_tables.map{|k| k.singularize.camelize.constantize }
      nodes = models.map{|k| table_dot(k)}.join("\n\n")
      edges = foreign_key_constraints.map{|k| "#{k[:child_table].singularize.camelize} -> #{k[:parent_table].singularize.camelize}"}.join("\n")
      edges2 = StudyRelationship.study_models.uniq.map{|k| "#{k.name} -> Study"}.join("\n")
    graph = <<-END
    digraph {
      graph [layout=twopi, splines=true, overlap=false];
      node [shape=plain]
      /*rankdir=LR;*/

      #{nodes}
      #{edges}
      #{edges2}
    }

    END

    File.write("./public/static/documentation/schema.dot", graph)
    `dot -Tpng ./public/static/documentation/schema.dot -o ./public/static/documentation/aact_schema.png`
    end

    def table_dot(model)
      attributes = model.columns_hash.map{|k,v| "<tr><td>#{k}</td><td>#{v.type}</td></tr>" }.join("\n")
      code = <<-END
        #{model.name} [label=<
        <table border="0" cellborder="1" cellspacing="0">
          <tr><td colspan="2"><b>#{model.name}</b></td></tr>
          #{attributes}
        </table>>];
      END
    end

    def one_to_one_related_tables
      [ 'brief_summaries', 'designs','detailed_descriptions', 'eligibilities', 'participant_flows', 'calculated_values' ]
    end

    def should_keep_index?(index)
      return true if index.table=='studies' and index.columns==['nct_id']
      return true if index.table=='study_xml_records' and index.columns==['nct_id']
      return true if index.table=='study_xml_records' and index.columns==['created_study_at']
      return true if index.table=='sanity_checks'
      false
    end

    def indexes_for(table_name)
      con.execute("select t.relname as table_name, i.relname as index_name, a.attname as column_name, ix.indisprimary as is_primary, ix.indisunique as is_unique from pg_class t, pg_class i, pg_index ix, pg_attribute a where t.oid = ix.indrelid and i.oid = ix.indexrelid and a.attrelid = t.oid and a.attnum = ANY(ix.indkey) and t.relkind = 'r' and t.relname = '#{table_name}';")
    end

    def public_con
      return @public_con if @public_con and @public_con.active?
      PublicBase.establish_connection(public_db_url)
      @public_con = PublicBase.connection
      @public_con.schema_search_path='ctgov'
      return @public_con
    end

    def public_alt_con
      return @public_alt_con if @public_alt_con and @public_alt_con.active?
      PublicBase.establish_connection(alt_db_url)
      @public_alt_con = PublicBase.connection
      @public_alt_con.schema_search_path='ctgov'
      return @public_alt_con
    end

    def con
      return @con if @con and @con.active?
      ActiveRecord::Base.establish_connection(back_db_url)
      @con = ActiveRecord::Base.connection
      # @con.schema_search_path=@search_path
      return @con
    end

    def self.con
      return @con if @con and @con.active?
      db_url = AACT::Application::AACT_BACK_DATABASE_URL
      ActiveRecord::Base.establish_connection(db_url)
      @con = ActiveRecord::Base.connection
      # @con.schema_search_path=@search_path
      return @con
    end

    def migration
      @migration_object ||= ActiveRecord::Migration.new
    end

    def public_host_name
      AACT::Application::AACT_PUBLIC_HOSTNAME
    end

    def background_db_name
      AACT::Application::AACT_BACK_DATABASE_NAME
    end

    def back_db_url
      AACT::Application::AACT_BACK_DATABASE_URL
    end

    def alt_db_url
      AACT::Application::AACT_ALT_PUBLIC_DATABASE_URL
    end

    def public_db_url
      AACT::Application::AACT_PUBLIC_DATABASE_URL
    end

    def alt_db_name
      AACT::Application::AACT_ALT_PUBLIC_DATABASE_NAME
    end

    def db_name
      AACT::Application::AACT_PUBLIC_DATABASE_NAME
    end

    def public_connection
      db = @config[:public]
      return unless db

      connection = PublicBase.establish_connection(db).connection
      connection.schema_search_path = 'ctgov'
      return connection
    end

    def staging_connection
      db = @config[:staging]
      return unless db

      connection = PublicBase.establish_connection(db).connection
      connection.schema_search_path = 'ctgov'
      return connection
    end

    def restore_from_file(path_to_file: "#{Rails.root}/tmp/postgres_data.dmp", database: 'aact')
      print 'restoring the database...'
      restore_database('normal', ActiveRecord::Base.connection, path_to_file)
      puts 'done'
    end

    def restore_from_url(params={})
      url = params[:url]
      database_name = params[:database_name] || 'aact'
      return unless url

      tries ||= 5
      file_path = "#{Rails.root}/tmp/snapshots"
      FileUtils.rm_rf(file_path)
      FileUtils.mkdir_p file_path
      file_name = "#{file_path}/snapshot.zip"
      file = File.new file_name, 'w'

      print 'downloading file...'
      begin
        `curl -o #{file.path} #{url}`
      rescue Errno::ECONNRESET => e
        if (tries -=1) > 0
          retry
        end
      end
      puts 'done'

      file.binmode

      print 'extracting postgres_data.dmp...'
      Zip::File.open(file) do |zip_file|
        zip_file.each do |f|
          if f.name == 'postgres_data.dmp'
            fpath = File.join(file_path, f.name)
            zip_file.extract(f, fpath) unless File.exist?(fpath)
          end
        end
      end
      puts 'done'

      restore_from_file({path_to_file: "#{file_path}/postgres_data.dmp", database: database_name})

      print 'removing temp folder...'
      FileUtils.rm_rf(file_path)
      puts 'done'
    end
  end
end
