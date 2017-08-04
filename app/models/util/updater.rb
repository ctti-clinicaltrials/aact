module Util
  class Updater
    attr_reader :params, :load_event, :client, :study_counts, :days_back, :rss_reader

    def initialize(params={})
      @params=params
      type=(params[:event_type] ? params[:event_type] : 'incremental')
      if params[:restart]
        puts("Starting the #{type} load...")
        record_type=type
      end
      @client = Util::Client.new
      @days_back=(@params[:days_back] ? @params[:days_back] : 4)
      @rss_reader = Util::RssReader.new(days_back: @days_back)
      @load_event = LoadEvent.create({:event_type=>record_type,:status=>'running',:description=>'',:problems=>''})
      @study_counts={:should_add=>0,:should_change=>0,:processed=>0,:count_down=>0}
      self
    end

    def run
      ActiveRecord::Base.logger=nil
      case params[:event_type]
        when 'full'
          full
        when 'finalize'
          finalize_full_load
        else
          incremental
      end
    end

    def full
      begin
        if should_restart?
          log("restarting full load...")
        else
          log('begin full load ...')
          retrieve_xml_from_ctgov
        end
        eta=(Time.now + 12.hours).strftime("%I:%M%p  %m/%d/%Y")
        submit_public_announcement("The AACT database is being refreshed and will be unavailable until approximately: #{eta} EST.  We apologize for the inconvenience.")
        revoke_db_privs
        truncate_tables if !should_restart?
        remove_indexes  # Index significantly slow the load process. Will be re-created after data loaded.
        study_counts[:should_add]=StudyXmlRecord.not_yet_loaded.count
        study_counts[:should_change]=0
        @client.populate_studies
        finalize_full_load
        PublicAnnouncement.destroy_all
      rescue  Exception => e
        study_counts[:processed]=Study.count
        puts ">>>>>>>>>>> Full load failed:  #{e}"
        grant_db_privs
        load_event.complete({:status=>'failed', :problems=> e.to_s, :study_counts=> study_counts})
        PublicAnnouncement.destroy_all
        send_notification
      end
    end

    def retrieve_xml_from_ctgov
      log("retrieving xml from clinicaltrials.gov ...")
      AdminBase.connection.truncate('study_xml_records')
      @client.save_file_contents(@client.download_xml_files)
    end

    def finalize_full_load
      begin
        remove_indexes  # Make sure indexes are gone before trying to add them.
        add_indexes
        MeshTerm.populate_from_file
        MeshHeading.populate_from_file
        create_calculated_values
      rescue
        grant_db_privs
      end
      grant_db_privs
      populate_admin_tables
      take_snapshot
      create_flat_files
      study_counts[:processed]=Study.count
      load_event.complete({:study_counts=>study_counts})
      send_notification
    end

    def populate_admin_tables
      run_sanity_checks
      refresh_data_definitions
    end

    def indexes
      [
         [:baseline_measurements, :dispersion_type],
         [:baseline_measurements, :param_type],
         [:overall_officials, :nct_id],
         [:responsible_parties, :nct_id],
         [:baseline_measurements, :category],
         [:baseline_measurements, :classification],
         [:browse_conditions, :nct_id],
         [:browse_conditions, :mesh_term],
         [:browse_conditions, :downcase_mesh_term],
         [:browse_interventions, :nct_id],
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
         [:studies, :first_received_results_date],
         [:studies, :received_results_disposit_date],
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

    def remove_indexes
      m=ActiveRecord::Migration.new
      Util::Updater.loadable_tables.each {|table_name|
        ActiveRecord::Base.connection.indexes(table_name).each{|index|
          m.remove_index(index.table, index.columns) if !should_keep_index?(index) and m.index_exists?(index.table, index.columns)
        }
      }
    end

    def create_calculated_values
      CalculatedValue.populate
    end

    def add_indexes
      m=ActiveRecord::Migration.new
      indexes.each{|index| m.add_index index.first, index.last  if !m.index_exists?(index.first, index.last)}
    end

    def incremental
      log("begin incremental load...")
      log("finding studies changed in past #{@days_back} days...")
      added_ids = @rss_reader.get_added_nct_ids
      changed_ids = @rss_reader.get_changed_nct_ids
      puts "#{changed_ids.size} changed studies: #{@rss_reader.changed_url}"
      puts "#{added_ids.size} added studies: #{@rss_reader.added_url}"
      ids=(changed_ids + added_ids).uniq
      log("total #{ids.size} studies combined (having removed dups)")
      case ids.size
      when 0
        load_event.complete({:new_studies=> 0, :changed_studies => 0, :status=>'no studies'})
        send_notification
        return
      when 10000..(1.0/0.0)
        log("Incremental load size is suspiciously large. Aborting load.")
        load_event.complete({:new_studies=> 0, :changed_studies => 0, :status=>'too many studies'})
        send_notification
        return
      end
      set_expected_counts(ids)
      submit_public_announcement("The AACT database is temporarily unavailable because the daily update is running.")
      remove_indexes  # Index significantly slow the load process.
      update_studies(ids)
      add_indexes
      CalculatedValue.populate
      populate_admin_tables
      log_actual_counts
      PublicAnnouncement.destroy_all
      load_event.complete({:study_counts=> study_counts})
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
      ActiveRecord::Base.connection.tables.reject{|table|blacklist.include?(table)}
    end

    def update_studies(nct_ids)
      log('update_studies...')
      ids=nct_ids.map { |i| "'" + i.to_s + "'" }.join(",")
      study_counts[:count_down]=nct_ids.size

      ActiveRecord::Base.transaction do
        Util::Updater.loadable_tables.each { |table|
          stime=Time.now
          ActiveRecord::Base.connection.execute("DELETE FROM #{table} WHERE nct_id IN (#{ids})")
          log("deleted studies from #{table}   #{Time.now - stime}")
        }
        AdminBase.connection.execute("DELETE FROM study_xml_records WHERE nct_id IN (#{ids})")
        nct_ids.each {|nct_id|
          refresh_study(nct_id)
          decrement_count_down
          show_progress(nct_id,'refreshing study')
        }
      end
      self
    end

    def log(msg)
      puts msg
      #load_event.log(msg)
    end

    def show_progress(nct_id,action)
      log("#{action}: #{study_counts[:count_down]} (#{nct_id})")
    end

    def decrement_count_down
      study_counts[:count_down]-=1
    end

    def run_sanity_checks
      log("sanity check...")
      SanityCheck.populate
    end

    def refresh_data_definitions(data=Util::FileManager.default_data_definitions)
      log("refreshing data definitions...")
      DataDefinition.populate(data)
    end

    def take_snapshot
      puts "creating static copy of the database..."
      Util::FileManager.new.take_snapshot
    end

    def create_flat_files
      log("exporting tables as flat files...")
      Util::TableExporter.new.run(delimiter: '|', should_archive: true)
    end

    def truncate_tables
      Util::Updater.loadable_tables.each { |table| ActiveRecord::Base.connection.truncate(table) }
    end

    def should_restart?
      @params[:restart]==true && StudyXmlRecord.not_yet_loaded.size > 0
    end

    def refresh_study(nct_id)
      stime=Time.now
      #  Call to ct.gov API has been known to timeout.  Catch it rather than abort the rest of the load
      #  Also, if a study is not found for the NCT ID we have, don't save an empty study
      begin
        new_xml=@client.get_xml_for(nct_id)
        StudyXmlRecord.create(:nct_id=>nct_id,:content=>new_xml)
        log("retrieved xml for #{nct_id}:  #{Time.now - stime}")
        stime=Time.now
        verify_xml=(new_xml.xpath('//clinical_study').xpath('source').text).strip
        if verify_xml.size > 1
          Study.new({ xml: new_xml, nct_id: nct_id }).create
          study_counts[:processed]+=1
          log("saved new data for #{nct_id}:  #{Time.now - stime}")
        else
          log("no data found for #{nct_id}")
        end
      rescue => error
        log("unable to save new data for #{nct_id}:  #{error}")
      end
    end

    def send_notification
      log("send email notification...")
      LoadMailer.send_notifications(load_event)
    end

    def set_expected_counts(ids)
      study_counts[:should_change] = (Study.pluck(:nct_id) & ids).count
      study_counts[:should_add]    = (ids.count - study_counts[:should_change])
      log("should change: #{study_counts[:should_change]};  should add: #{study_counts[:should_add]}\n")
    end

    def log_actual_counts
      log("studies added/changed: #{study_counts[:processed]}\n")
    end

private

    def revoke_db_privs
      con=ActiveRecord::Base.connection
      con.execute("revoke connect on database #{db_name} from aact;")
      con.execute("revoke select on all tables in schema public from aact;")
      con.execute("revoke all on schema public from public;")
      con.execute("revoke all on schema public from aact;")
    end

    def grant_db_privs
      # some of this may seem redundant & better placed in revoke_db_privs, but the following works to allow aact user to
      # select from tables, but not update the tables nor create new tables
      con=ActiveRecord::Base.connection
      con.execute("revoke all on all tables in schema public from aact;")
      con.execute("revoke all on schema public from aact;")
      con.execute("revoke all on schema public from public;")
      con.execute("revoke usage on schema public from public;")
      con.execute("grant connect on database #{db_name} to aact;")
      con.execute("grant usage on schema public TO aact;")
      con.execute('grant select on all tables in schema public to aact;')
    end

    def db_name
      ActiveRecord::Base.connection.current_database
    end

    def submit_public_announcement(announcement)
      PublicAnnouncement.populate(announcement)
    end

  end
end
