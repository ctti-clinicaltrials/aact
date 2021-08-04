# frozen_string_literal: true

module Util
  class Updater
    attr_reader :params, :load_event, :client, :study_counts, :days_back, :rss_reader, :full_featured, :schema, :search_days_back

    # days_back:     number of days
    # full_featured: restore public db if true
    # event_type:    type of load 'full' or 'incremental'
    # restart:       restart an existing load
    def initialize(params = {})
      @full_featured = params[:full_featured] || false
      @params = params
      type = (params[:event_type] || 'incremental')
      @schema = params[:schema]
      @search_days_back = params[:search_days_back]
      ENV['load_type'] = type
      if params[:restart]
        log("Starting the #{type} load...")
        type = 'restart'
      end
      @client = Util::Client.new
      @days_back = (params[:days_back] || 4)
      @rss_reader = Util::RssReader.new(days_back: @days_back)
      @load_event = Support::LoadEvent.create({ event_type: type, status: 'running', description: '', problems: '' })
      @load_event.save! # Save to timestamp created_at
      @study_counts = { should_add: 0, should_change: 0, processed: 0, count_down: 0 }
      self
    end

    def execute
      # TODO: need to extract this into a connection method
      con = ActiveRecord::Base.connection
      username = ENV['AACT_DB_SUPER_USERNAME'] || 'ctti'
      db_name = ENV['AACT_BACK_DATABASE_NAME'] || 'aact'
      if schema == 'beta'
        con.execute("ALTER ROLE #{username} IN DATABASE #{db_name} SET SEARCH_PATH TO ctgov_beta, support, public;")
      else
        con.execute("ALTER ROLE #{username} IN DATABASE #{db_name} SET SEARCH_PATH TO ctgov, support, public;")
      end
      ActiveRecord::Base.remove_connection
      ActiveRecord::Base.establish_connection
      ActiveRecord::Base.logger = nil

      # 1. remove constraings
      log("#{schema} remove constraints...")
      db_mgr.remove_constrains

      # 2. update studies
      log("#{schema} updating studies...")
      update_studies

      # 3. add constraints
      log("#{schema} adding constraints...")
      db_mgr.add_constraints

      # 4. run study searches
      log("#{schema} execute study search...")
      StudySearch.execute(search_days_back)

      # 5. update calculated values
      log("#{schema} update calculated values...")
      CalculatedValue.populate

      # 6. run sanity checks
      load_event.run_sanity_checks

      if load_event.sanity_checks.count == 0
        # 7. take snapshot
        log("#{schema} take snapshot...")
        take_snapshot(schema)

        # 8. refresh public db
        log("#{schema} refresh public db...")
        db_mgr.refresh_public_db(schema)

        # 9. create flat files
        if schema == 'beta'
        else
          log("#{schema} creating flat files...")
          begin
            create_flat_files(schema)
          rescue Exception => e
            Airbrake.notify(e)
          end
          create_flat_files(schema)
        end
      end

      # 10. send email
      send_notification(schema)
    end

    def current_study_differences
      studies = ClinicalTrialsApi.all
      puts "aact  study count: #{Study.count}"
      puts "ctgov study count: #{studies.count}"

      # find all the studies that need to be updated
      current = Hash[Study.pluck(:nct_id, :last_update_posted_date)]
      ids = studies.select do |entry|
        current_date = current[entry[:id]]
        current_date.nil? || entry[:updated] > current_date
      end
      to_update = ids.map {|k| k[:id] }

      # find all the studies that need to be removed
      current = current.keys
      studies = studies.map{|k| k[:id] }
      to_remove = current - studies

      return studies, to_update, to_remove
    end

    def update_studies
      studies, to_update, to_remove = current_study_differences

      log("#{schema} updating #{to_update.length} studies")
      log("#{schema} removing #{to_remove.length} studies")

      # update studies
      total = to_update.length
      total_time = 0
      stime = Time.now
      to_update.each_with_index do |id, idx|
        t = update_study(id)
        total_time += t
        avg_time = total_time / (idx + 1)
        remaining = (total - idx - 1) * avg_time
        puts "#{total - idx} #{id} #{t} #{htime(total_time)} #{htime(remaining)}"
      end
      time = Time.now - stime
      puts "Time: #{time} avg: #{time / total}"

      # remove studies
      raise "Removing too many studies #{to_remove.count}" if studies.count > Study.count - to_remove.count
      total = to_remove.length
      total_time = 0
      stime = Time.now
      to_remove.each_with_index do |id, idx|
        t = remove_study(id)
        total_time += t
        avg_time = total_time / (idx + 1)
        remaining = (total - idx - 1) * avg_time
        puts "#{total - idx} #{id} #{t} #{htime(total_time)} #{htime(remaining)}"
      end
    end

    def htime(seconds)
      seconds = seconds.to_i
      hours = seconds / 3600
      seconds -= hours * 3600
      minutes = seconds / 60
      seconds -= minutes * 60
      "#{hours}:#{'%02i' % minutes}:#{'%02i' % seconds}"
    end

    def update_study(id)
      stime = Time.now
      if schema == 'beta'
        record = StudyJsonRecord.find_or_create_by(nct_id: id)
        changed = record.update_from_api
        record.create_or_update_study
      else
        record = Support::StudyXmlRecord.find_or_create_by(nct_id: id)
        changed = record.update_xml_from_api
        record.create_or_update_study
      end
      Time.now - stime
    end

    def remove_study(id)
      stime = Time.now
      study = Study.find_by(nct_id: id)
      study.remove_study_data if study
      Time.now - stime
    end

    def run
      begin
        ActiveRecord::Base.logger = nil
        status = case params[:event_type]
                 when 'full'
                   full
                 else
                   incremental
                 end
        finalize_load if status != false
      rescue StandardError => e
        begin
          msg = "#{e.message} (#{e.class} #{e.backtrace}"
          log("#{@load_event.event_type} load failed in run: #{msg}")
          load_event.add_problem(msg)
          load_event.complete({ status: 'failed', study_counts: study_counts })
          db_mgr.grant_db_privs
          Admin::PublicAnnouncement.clear_load_message if full_featured && Admin::AdminBase.database_exists?
        rescue StandardError
          load_event.complete({ status: 'failed', study_counts: study_counts })
        end
      end
      send_notification
    end

    def full
      if should_restart?
        log('restarting full load...')
      else
        log('begin full load ...')
        retrieve_xml_from_ctgov
      end
      truncate_tables unless should_restart?
      remove_indexes_and_constraints # Index significantly slow the load process. Will be re-created after data loaded.
      study_counts[:should_add] = Support::StudyXmlRecord.not_yet_loaded.count
      study_counts[:should_change] = 0
      @client.populate_studies
      MeshTerm.populate_from_file
      MeshHeading.populate_from_file
    end

    # incremental steps
    # 1. update studies
    # 2. update calculated values
    # 3. run saved searches
    def incremental
      log('begin incremental load...')

      db_mgr.remove_constrains
      Support::StudyXmlRecord.update_studies
      db_mgr.add_constraints

      log('end of incremental load method')
      true
    end

    def retrieve_xml_from_ctgov
      log('retrieving xml from clinicaltrials.gov...')
      Support::SupportBase.connection.execute('TRUNCATE TABLE study_xml_records CASCADE')
      @client.save_file_contents(@client.download_xml_files)
    end

    # Steps:
    # 1. add indexes and constraints
    # 2. execute saved search
    # 3. create calculated values
    # 4. populate admin tables
    # 5. run sanity checks
    # 6. take snapshot
    # 7. refreh public db
    # 8. create flat files
    def finalize_load
      log('finalizing load...')

      load_event.log('add indexes and constraints..')
      add_indexes_and_constraints if params[:event_type] == 'full'

      load_event.log('execute study search...')
      days_back = (Date.today - Date.parse('2013-01-01')).to_i if load_event.event_type == 'full'
      StudySearch.execute(days_back)

      if params[:event_type] == 'full'
        load_event.log('create calculated values...')
        create_calculated_values
        load_event.log('set downcase mesh terms...')
        create_downcase_mesh_terms
      end

      load_event.log('populate admin tables...')
      # populate_admin_tables

      load_event.log('run sanity checks...')
      run_sanity_checks

      return unless full_featured # no need to continue unless configured as a fully featured implementation of AACT

      study_counts[:processed] = Study.count

      load_event.log('taking snapshot...')
      take_snapshot

      load_event.log('refreshing public db...')
      if refresh_public_db != true
        load_event.problems = 'DID NOT UPDATE PUBLIC DATABASE.' + load_event.problems
        load_event.save!
      end

      load_event.complete({ study_counts: study_counts })

      load_event.log('create flat files...')
      create_flat_files

      # Admin::PublicAnnouncement.clear_load_message
    end

    def remove_indexes_and_constraints
      log('removing indexes...')
      db_mgr.remove_indexes_and_constraints
    end

    def add_indexes_and_constraints
      log('adding indexes...')
      db_mgr.add_indexes_and_constraints
    end

    def create_calculated_values
      log('creating calculated values...')
      CalculatedValue.populate
    end

    def create_downcase_mesh_terms
      log('setting downcase mesh terms...')
      con=ActiveRecord::Base.connection
      #  save a lowercase version of MeSH terms so they can be found without worrying about case
      con.execute("UPDATE browse_conditions SET downcase_mesh_term=lower(mesh_term);")
      con.execute("UPDATE browse_interventions SET downcase_mesh_term=lower(mesh_term);")
      con.execute("UPDATE keywords SET downcase_name=lower(name);")
      con.execute("UPDATE conditions SET downcase_name=lower(name);")
    end

    def log(msg)
      puts "#{Time.zone.now}: #{msg}"
    end

    def show_progress(nct_id, action)
      log("#{action}: #{nct_id} - #{study_counts[:count_down]}")
    end

    def decrement_count_down
      study_counts[:count_down] -= 1
    end

    def populate_admin_tables
      return unless full_featured

      log('populating admin tables...')
      refresh_data_definitions
    end

    def run_sanity_checks
      log('running sanity checks...')
      Support::SanityCheck.new.run
    end

    def refresh_data_definitions(data = Util::FileManager.new.default_data_definitions)
      return unless Admin::AdminBase.database_exists?

      log('refreshing data definitions...')
      Admin::DataDefinition.populate(data)
    end

    def take_snapshot(schema)
      log('dumping database...')
      db_mgr.dump_database(schema)

      if schema != 'beta'
        log('creating zipfile of database...')
        Util::FileManager.new.save_static_copy
      end
    rescue StandardError => e
      load_event.add_problem("#{e.message} (#{e.class} #{e.backtrace}")
    end

    def send_notification(schema)
      return unless AACT::Application::AACT_OWNER_EMAIL

      log('sending email notification...')
      Notifier.report_load_event(schema, load_event)
    end

    def create_flat_files(schema)
      log('exporting tables as flat files...')
      Util::TableExporter.new.run(delimiter: '|', should_archive: true)
    end

    def truncate_tables
      log('truncating tables...')
      Util::DbManager.loadable_tables.each do |table|
        ActiveRecord::Base.connection.execute("TRUNCATE TABLE #{table} CASCADE")
      end
    end

    def should_restart?
      @params[:restart] && !Support::StudyXmlRecord.not_yet_loaded.empty?
    end

    def refresh_public_db
      return unless full_featured

      log('refreshing public db...')
      # recreate public db from back-end db
      if sanity_checks_ok?
        # submit_public_announcement("The AACT database is temporarily unavailable because it's being updated.")
        db_mgr.refresh_public_db
        true
      else
        load_event.save!
        false
      end
    end

    def db_mgr
      @db_mgr ||= Util::DbManager.new(event: load_event)
    end

    # Admin Database

    def submit_public_announcement(announcement)
      Admin::PublicAnnouncement.populate(announcement) if full_featured && Admin::AdminBase.database_exists?
    end
  end
end
