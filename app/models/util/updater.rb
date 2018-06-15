module Util
 class Updater
    attr_reader :params, :load_event, :client, :study_counts, :days_back, :rss_reader, :db_mgr

    def initialize(params={})
      @params=params
      type=(params[:event_type] ? params[:event_type] : 'incremental')
      if params[:restart]
        log("Starting the #{type} load...")
        type='restart'
      end
      @client = Util::Client.new
      @days_back=(@params[:days_back] ? @params[:days_back] : 2)
      @rss_reader = Util::RssReader.new(days_back: @days_back)
      @load_event = Admin::LoadEvent.create({:event_type=>type,:status=>'running',:description=>'',:problems=>''})
      @load_event.save!  # Save to timestamp created_at
      @study_counts={:should_add=>0,:should_change=>0,:processed=>0,:count_down=>0}
      self
    end

    def run
      status=true
      begin
        ActiveRecord::Base.logger=nil
        case params[:event_type]
        when 'full'
          status=full
        else
          status=incremental
        end
        finalize_load if status != false
      rescue => error
        begin
          status=false
          msg="#{error.message} (#{error.class} #{error.backtrace}"
          log("#{@load_event.event_type} load failed in run: #{msg}")
          load_event.add_problem(msg)
          load_event.complete({:status=>'failed', :study_counts=> study_counts})
          Admin::PublicAnnouncement.clear_load_message
          db_mgr.grant_db_privs
        rescue
          load_event.complete({:status=>'failed', :study_counts=> study_counts})
        end
      end
      send_notification
    end

    def full
      if should_restart?
        log("restarting full load...")
      else
        log('begin full load ...')
        retrieve_xml_from_ctgov
      end
      truncate_tables if !should_restart?
      remove_indexes  # Index significantly slow the load process. Will be re-created after data loaded.
      study_counts[:should_add]=StudyXmlRecord.not_yet_loaded.count
      study_counts[:should_change]=0
      @client.populate_studies
      # for now, just remove daily files from command line
      #remove_last_months_download_files if Date.today.day == 1  # only do this if it's the first of the month
      MeshTerm.populate_from_file
      MeshHeading.populate_from_file
    end

    def incremental
      log("begin incremental load...")
      log("finding studies changed in past #{@days_back} days...")
      added_ids = @rss_reader.get_added_nct_ids
      changed_ids = @rss_reader.get_changed_nct_ids
      log("#{added_ids.size} added studies: #{@rss_reader.added_url}")
      log("#{changed_ids.size} changed studies: #{@rss_reader.changed_url}")
      study_counts[:should_add]=added_ids.size
      study_counts[:should_change]=changed_ids.size
      ids=(changed_ids + added_ids).uniq
      log("total #{ids.size} studies combined (having removed dups)")
      case ids.size
      when 0
        load_event.complete({:new_studies=> 0, :changed_studies => 0, :status=>'no studies'})
        return false
      when 10000..(1.0/0.0)
        log("Incremental load size is suspiciously large. Aborting load.")
        load_event.complete({:new_studies=> 0, :changed_studies => 0, :status=>'too many studies'})
        return false
      end
      remove_indexes  # Index significantly slow the load process.
      update_studies(ids)
      log('updating load_event record...')
      load_event.save_id_info(added_ids, changed_ids)
      log('end of incremental load method')
    end

    def retrieve_xml_from_ctgov
      log("retrieving xml from clinicaltrials.gov...")
      Admin::AdminBase.connection.truncate('study_xml_records')
      @client.save_file_contents(@client.download_xml_files)
    end

    def finalize_load
      log('finalizing load...')
      add_indexes
      create_calculated_values
      populate_admin_tables
      study_counts[:processed]=Study.count
      take_snapshot
      if refresh_public_db != true
        load_event.problems="DID NOT UPDATE PUBLIC DATABASE." + load_event.problems
        load_event.save!
      end
      Util::UserDbManager.new.backup_user_info
      db_mgr.grant_db_privs
      load_event.complete({:study_counts=>study_counts})
      create_flat_files
      Admin::PublicAnnouncement.clear_load_message
    end

    def remove_indexes
      log('removing indexes...')
      db_mgr.remove_indexes
    end

    def add_indexes
      log('adding indexes...')
      db_mgr.add_indexes
    end

    def create_calculated_values
      log('creating calculated values...')
      CalculatedValue.populate
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
#      table_names.each{|table_name| table_name.singularize.camelize.constantize
    end

    def update_studies(nct_ids)
      log("updating the set of studies (#{nct_ids.size})...")
      ids=nct_ids.map { |i| "'" + i.to_s + "'" }.join(",")
      study_counts[:count_down]=nct_ids.size

      ActiveRecord::Base.transaction do
        db_mgr.loadable_tables.each { |table|
          stime=Time.zone.now
          ActiveRecord::Base.connection.execute("DELETE FROM #{table} WHERE nct_id IN (#{ids})")
          log("deleted studies from #{table}   #{Time.zone.now - stime}")
        }
        Admin::AdminBase.connection.execute("DELETE FROM study_xml_records WHERE nct_id IN (#{ids})")
        nct_ids.each {|nct_id|
          refresh_study(nct_id)
          decrement_count_down
        }
      end
      log("finished iterating over #{nct_ids.size} studies")
      self
    end

    def log(msg)
      puts "#{Time.zone.now}: #{msg}"  # log to STDOUT
    end

    def show_progress(nct_id,action)
      log("#{action}: #{nct_id} - #{study_counts[:count_down]}")
    end

    def decrement_count_down
      study_counts[:count_down]-=1
    end

    def populate_admin_tables
      log('populating admin tables...')
      refresh_data_definitions
      run_sanity_checks
    end

    def run_sanity_checks
      log("running sanity checks...")
      Admin::SanityCheck.new.run(params[:event_type])
    end

    def sanity_checks_ok?
      log "sanity checks ok?...."
      Admin::SanityCheck.current_issues.each{|issue| load_event.add_problem(issue) }
      sanity_set=Admin::SanityCheck.where('most_current is true')
      load_event.add_problem("Fewer sanity check rows than expected (42): #{sanity_set.size}.") if sanity_set.size < 42
      load_event.add_problem("More sanity check rows than expected (42): #{sanity_set.size}.") if sanity_set.size > 42
      load_event.add_problem("Sanity checks ran more than 2 hours ago: #{sanity_set.max_by(&:created_at)}.") if sanity_set.max_by(&:created_at).created_at < (Time.zone.now - 2.hours)
      # because ct.gov cleans up and removes duplicate studies, sometimes the new count is a bit less then the old count.
      # Fudge up by 10 studies to avoid incorrectly preventing a refresh due to this.
      old_count=(db_mgr.public_study_count - 10)
      new_count=db_mgr.background_study_count
      load_event.add_problem("New db has fewer studies (#{new_count}) than current public db (#{old_count})") if old_count > new_count
      return load_event.problems.blank?
    end

    def refresh_data_definitions(data=Util::FileManager.new.default_data_definitions)
      log("refreshing data definitions...")
      Admin::DataDefinition.populate(data)
    end

    def take_snapshot
      log("creating downloadable versions of the database...")
      begin
        db_mgr.dump_database
        Util::FileManager.new.save_static_copy
      rescue => error
        load_event.add_problem("#{error.message} (#{error.class} #{error.backtrace}")
      end
    end

    def remove_last_months_download_files
      log("removing daily downloadable files from last month...")
      file_mgr=Util::FileManager.new
      file_mgr.remove_daily_snapshots
      file_mgr.remove_daily_flat_files
    end

    def send_notification
      log("sending email notification...")
      Notifier.report_load_event(load_event)
    end

    def create_flat_files
      log("exporting tables as flat files...")
      Util::TableExporter.new.run(delimiter: '|', should_archive: true)
    end

    def truncate_tables
      log('truncating tables...')
      Util::Updater.loadable_tables.each { |table| ActiveRecord::Base.connection.truncate(table) }
    end

    def should_restart?
      @params[:restart]==true && StudyXmlRecord.not_yet_loaded.size > 0
    end

    def refresh_study(nct_id)
      stime=Time.zone.now
      #  Call to ct.gov API has been known to timeout.  Catch it rather than abort the rest of the load
      #  Also, if a study is not found for the NCT ID we have, don't save an empty study
      begin
        new_xml=@client.get_xml_for(nct_id)
        StudyXmlRecord.create(:nct_id=>nct_id,:content=>new_xml)
        stime=Time.zone.now
        verify_xml=(new_xml.xpath('//clinical_study').xpath('source').text).strip
        if verify_xml.size > 1
          Study.new({ xml: new_xml, nct_id: nct_id }).create
          study_counts[:processed]+=1
          show_progress(nct_id, " refreshed #{Time.zone.now - stime}")
        else
          log("no data found for #{nct_id}")
        end
      rescue => error
        log("unable to refresh #{nct_id}: #{error.message} (#{error.class} #{error.backtrace}")
      end
    end

    def refresh_public_db
      log('refreshing public db...')
      # recreate public db from back-end db
      if sanity_checks_ok?
        submit_public_announcement("The AACT database is temporarily unavailable because it's being updated.")
        db_mgr.refresh_public_db
        return true
      else
        load_event.save!
        return false
      end
    end

    def log_actual_counts
      log("studies added/changed: #{study_counts[:processed]}\n")
    end

    def db_mgr
      @db_mgr ||= Util::DbManager.new({:event=>self.load_event})
    end

    def db_name
      ActiveRecord::Base.connection.current_database
    end

    def submit_public_announcement(announcement)
      Admin::PublicAnnouncement.populate(announcement)
    end

  end
end
