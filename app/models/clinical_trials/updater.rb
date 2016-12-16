module ClinicalTrials
  class Updater
    attr_reader :params, :load_event, :client, :study_counts, :download_file_name

    def initialize(params={})
      @params=params
      type=(params[:event_type] ? params[:event_type] : 'incremental')
      puts "Restarting the load..." if params[:restart]
      @client = ClinicalTrials::Client.new
      @load_event = ClinicalTrials::LoadEvent.create({:event_type=>type,:status=>'running',:description=>'',:problems=>''})
      @study_counts={:should_add=>0,:should_change=>0,:add=>0,:change=>0,:count_down=>0}
      self
    end

    def run
      if @load_event.event_type=='full'
        full
      else
        incremental
      end
    end

    def full
      log('begin ...')
      if should_restart?
        puts "restarting full load process..."
      else
        puts "initiating full load..."
        @client.download_xml_files
        truncate_tables
      end
      remove_indexes  # Index significantly slow the load process.
      create_studies
      add_indexes
      run_sanity_checks
      export_tables
      send_notification
      @load_event.complete({:new_studies=> Study.count})
    end

    def indexes
      [
       [:baseline_measures, :category],
       [:baseline_measures, :classification],
       [:browse_interventions, :nct_id],
       [:overall_officials, :nct_id],
       [:responsible_parties, :nct_id],
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
       [:responsible_parties, :organization],
       [:result_contacts, :organization],
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

    def remove_indexes
      m=ActiveRecord::Migration.new
      ClinicalTrials::Updater.loadable_tables.each {|table_name|
        ActiveRecord::Base.connection.indexes(table_name).each{|index|
          m.remove_index index.table, index.columns
        }
      }
    end

    def add_indexes
      m=ActiveRecord::Migration.new
      indexes.each{|index| m.add_index index.first, index.last}
    end

    def incremental
      log("begin ...")
      days_back=(@params[:days_back] ? @params[:days_back] : 1)
      log("finding studies changed in past #{days_back} days...")
      ids = ClinicalTrials::RssReader.new(days_back: days_back).get_changed_nct_ids
      log("found #{ids.size} studies that have changed")
      set_expected_counts(ids)
      update_studies(ids)
      run_sanity_checks
      export_tables
      log_actual_counts
      @load_event.complete({:new_studies=> @study_counts[:add], :changed_studies => @study_counts[:change]})
      send_notification
    end

    def self.loadable_tables()
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
      @load_event.log(msg)
    end

    def show_progress(nct_id,action)
      @load_event.log("#{action}: #{@study_counts[:count_down]} (#{nct_id})")
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

    def create_studies
      log("create studies...")
      @client.populate_studies
    end

    def run_sanity_checks
      log("sanity check...")
      SanityCheck.run
    end

    def export_tables
      if !@params[:create_snapshots]==false
        log("exporting tables...")
        TableExporter.new.run
      end
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
      Study.new({ xml: new_xml, nct_id: nct_id }).create
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
  end
end
