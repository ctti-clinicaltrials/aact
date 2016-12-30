module ClinicalTrials
  class Updater
    attr_reader :params, :load_event, :client, :study_counts, :study_filter

    def initialize(params={})
      @params=params
      type=(params[:event_type] ? params[:event_type] : 'incremental')
      if params[:restart]
        puts("Restarting the load...")
        # don't allow filtering by nct ID unless it's a restart because filtering is done so that multiple loads can run simultaneously
        # if multiple jobs running for initial full load - they would step on each ther when study_xml_records table gets truncated
        @study_filter=@params[:study_filter]
        record_type="Restart #{@study_filter}"
      else
        puts("Starting the #{type} load...")
        record_type=type
      end
      @client = ClinicalTrials::Client.new
      @load_event = ClinicalTrials::LoadEvent.create({:event_type=>record_type,:status=>'running',:description=>'',:problems=>''})
      @study_counts={:should_add=>0,:should_change=>0,:add=>0,:change=>0,:count_down=>0}
      self
    end

    def run
      if study_filter
        @client.populate_studies(study_filter)
        @load_event.complete({:new_studies=> Study.count})
      else
        case params[:event_type]
        when 'full'
          full
        when 'finalize'
          finalize_full_load
        else
          incremental
        end
      end
    end

    def full
      begin
        log('begin ...')
        revoke_db_privs
        if should_restart?
          log("restarting full load...")
        else
          log("initiating full load...")
          ActiveRecord::Base.connection.truncate('study_xml_records')
          @client.download_xml_files
          truncate_tables
        end
        remove_indexes  # Index significantly slow the load process.
        @client.populate_studies
        finalize_full_load
        @load_event.complete({:new_studies=> Study.count})
      rescue e
        puts "Full load failed:  #{e}"
        grant_db_privs
        @load_event.complete({:status=>'failed', :problems=> e.to_s, :new_studies=> Study.count})
      end
    end

    def finalize_full_load
      add_indexes
      grant_db_privs
      create_calculated_values
      run_sanity_checks
      take_snapshot
      create_flat_files
      send_notification
      @load_event.complete({:new_studies=> Study.count})
    end

    def indexes
      [
       [:browse_interventions, :nct_id],
       [:overall_officials, :nct_id],
       [:responsible_parties, :nct_id],
       [:baseline_measures, :category],
       [:baseline_measures, :classification],
       [:browse_conditions, :mesh_term],
       [:browse_interventions, :mesh_term],
       [:calculated_values, :actual_duration],
       [:calculated_values, :months_to_report_results],
       [:calculated_values, :number_of_facilities],
       [:calculated_values, :primary_completion_date],
       [:calculated_values, :sponsor_type],
       [:calculated_values, :start_date],
       [:designs, :masking],
       [:designs, :subject_masked],
       [:designs, :caregiver_masked],
       [:designs, :investigator_masked],
       [:designs, :outcomes_assessor_masked],
       [:eligibilities, :gender],
       [:eligibilities, :healthy_volunteers],
       [:eligibilities, :minimum_age],
       [:eligibilities, :maximum_age],
       [:facilities, :name],
       [:facilities, :city],
       [:facilities, :state],
       [:facilities, :country],
       [:overall_officials, :affiliation],
       [:oversight_authorities, :name],
       [:outcome_measurements, :category],
       [:outcome_measurements, :classification],
       [:reported_events, :event_type],
       [:reported_events, :subjects_affected],
       [:responsible_parties, :organization],
       [:result_contacts, :organization],
       [:sponsors, :agency_class],
       [:sponsors, :name],
       [:studies, :overall_status],
       [:studies, :phase],
       [:studies, :last_known_status],
       [:studies, :primary_completion_date_type],
       [:studies, :source],
       [:studies, :study_type],
       [:studies, :first_received_results_date],
       [:studies, :received_results_disposit_date]
      ]
    end

    def should_keep_index?(index)
      return true if index.table=='studies' and index.columns==['nct_id']
      return true if index.table=='study_xml_records' and index.columns==['nct_id']
      return true if index.table=='study_xml_records' and index.columns==['created_study_at']
      false
    end

    def remove_indexes
      m=ActiveRecord::Migration.new
      ClinicalTrials::Updater.loadable_tables.each {|table_name|
        ActiveRecord::Base.connection.indexes(table_name).each{|index|
          m.remove_index(index.table, index.columns) unless should_keep_index?(index)
        }
      }
    end

    def create_calculated_values
      CalculatedValue.refresh_table
    end

    def add_indexes
      m=ActiveRecord::Migration.new
      indexes.each{|index| m.add_index index.first, index.last}
    end

    def incremental
      log("begin incremental load...")
      days_back=(@params[:days_back] ? @params[:days_back] : 4)
      log("finding studies changed in past #{days_back} days...")
      ids = ClinicalTrials::RssReader.new(days_back: days_back).get_changed_nct_ids
      log("found #{ids.size} studies that have been changed or added")
      set_expected_counts(ids)
      ActiveRecord::Base.connection.execute('REVOKE CONNECT ON DATABASE aact FROM aact;')
      update_studies(ids)
      ActiveRecord::Base.connection.execute('GRANT CONNECT ON DATABASE aact TO aact;')
      CalculatedValue.refresh_table_for_studies(ids)
      run_sanity_checks
      #take_snapshot
      #create_flat_files
      log_actual_counts
      @load_event.complete({:new_studies=> @study_counts[:add], :changed_studies => @study_counts[:change]})
      send_notification
    end

    def self.single_study_tables
      [
        'brief_summaries',
        'designs',
        'detailed_descriptions',
        'eligibilities',
        'participant_flows',
        'calculated_values',
        'studies'
      ]
    end

    def self.loadable_tables
      blacklist = %w(
        schema_migrations
        load_events
        sanity_checks
        statistics
        study_xml_records
        use_cases
        use_case_attachments
      )
      ActiveRecord::Base.connection.tables.reject{|table|blacklist.include?(table)}
    end

    def set_count_down(sum)
      @study_counts[:count_down]=sum
    end

    def update_studies(nct_ids)
      log('update_studies...')
      set_count_down(nct_ids.size)
      nct_ids.each {|nct_id|
        refresh_study(nct_id)
        decrement_count_down
        show_progress(nct_id,'refreshing study')
      }
      self
    end

    def log(msg)
      puts msg
      #@load_event.log(msg)
    end

    def show_progress(nct_id,action)
      log("#{action}: #{@study_counts[:count_down]} (#{nct_id})")
    end

    def decrement_count_down
      @study_counts[:count_down]-=1
    end

    def increment_study_counts(study_exists)
      if study_exists > 0
        @study_counts[:change]+=1
      else
        @study_counts[:add]+=1
      end
    end

    def run_sanity_checks
      log("sanity check...")
      SanityCheck.save_row_counts
    end

    def take_snapshot
      puts "snapshot the database..."
      ClinicalTrials::FileManager.new.take_snapshot
      log("exporting tables as flat files...")
      TableExporter.new.run
    end

    def create_flat_files
      TableExporter.new.run(delimiter: '|', should_upload_to_s3: true)
    end

    def truncate_tables
      ClinicalTrials::Updater.loadable_tables.each { |table| ActiveRecord::Base.connection.truncate(table) }
    end

    def should_restart?
      @params[:restart]==true && StudyXmlRecord.not_yet_loaded.size > 0
    end

    def refresh_study(nct_id)
      old_xml_record = StudyXmlRecord.where(nct_id: nct_id) #should only be one
      old_study=Study.where(nct_id: nct_id)    #should only be one
      increment_study_counts(old_study.size)
      old_xml_record.each{|old| old.destroy }  # but remove all... just in case
      old_study.each{|old| old.destroy }
      new_xml=@client.get_xml_for(nct_id)
      StudyXmlRecord.create(:nct_id=>nct_id,:content=>new_xml)
      s=Study.new({ xml: new_xml, nct_id: nct_id }).create
    end

    def send_notification
      log("send email notification...")
      LoadMailer.send_notifications(@load_event)
    end

    def set_expected_counts(ids)
      @study_counts[:should_change] = (Study.pluck(:nct_id) & ids).count
      @study_counts[:should_add]    = (ids.count - @study_counts[:should_change])
      log("should change: #{@study_counts[:should_change]};  should add: #{@study_counts[:should_add]}\n")
    end

    def log_actual_counts
      log("should change: #{@study_counts[:change]};  should add: #{@study_counts[:add]}\n")
    end

    private

    def revoke_db_privs
      ActiveRecord::Base.connection.execute("REVOKE ALL PRIVILEGES ON database #{db_name} FROM aact;")
    end

    def grant_db_privs
      ActiveRecord::Base.connection.execute("GRANT CONNECT ON DATABASE #{db_name} TO aact;")
      ActiveRecord::Base.connection.execute('GRANT SELECT ON ALL TABLES IN SCHEMA public TO aact;')
    end

    def db_name
      ActiveRecord::Base.connection.current_database
    end

  end
end
