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
      @type = (params[:event_type] || 'incremental')
      @schema = params[:schema] || 'ctgov'
      @search_days_back = params[:search_days_back]
      ENV['load_type'] = @type
      if params[:restart]
        log("Starting the #{@type} load...")
        @type = 'restart'
      end
      @days_back = (params[:days_back] || 4)
      @study_counts = { should_add: 0, should_change: 0, processed: 0, count_down: 0 }
      self
    end

    def start
      loop do
        now = TZInfo::Timezone.get('America/New_York').now
        if Support::LoadEvent.where('created_at > ?',now.beginning_of_day).count == 0
          execute
        else
          ActiveRecord::Base.logger = nil
          db_mgr.remove_constraints
          update_old_studies
        end
      end
    end

    # updates the oldest studies
    def update_old_studies(count=100)
      # ids = Study.where('updated_at < ?',Time.now-24.hours).order(updated_at: :asc).limit(count)
      studies = Study.order(updated_at: :asc).limit(count)
      puts "refreshing #{studies.count} studies"
      studies.each do |study|
        puts "refresh #{study.nct_id} #{study.updated_at}"
        update_study(study.nct_id)
      end
    end

    def execute
      @load_event = Support::LoadEvent.create({ event_type: @type, status: 'running', description: '', problems: '' })
      # TODO: need to extract this into a connection method
      ActiveRecord::Base.logger = nil

      # 1. remove constraings
      log("#{schema} remove constraints...")
      db_mgr.remove_constraints

      # 2. update studies
      log("#{schema} updating studies...")
      update_studies

      # 3. add constraints
      log("#{schema} adding constraints...")
      db_mgr.add_constraints

      # 4. comparing the counts from CT.gov to our database
      log("#{schema} comparing counts...")
      begin
        Verifier.refresh({schema: schema, load_event_id: @load_event.id})
      rescue => e
        Airbrake.notify(e)
      end

      # 5. run study searches
      log("#{schema} execute study search...")
      StudySearch.execute(search_days_back)

      # 6. update calculated values
      log("#{schema} update calculated values...")
      CalculatedValue.populate

      # 6a. populate the meshterms and meshheadings
      MeshTerm.populate_from_file
      MeshHeading.populate_from_file
      set_downcase_terms

      # 7. run sanity checks
      load_event.run_sanity_checks

      if load_event.sanity_checks.count == 0
        # 8. take snapshot
        log("#{schema} take snapshot...")
        take_snapshot

        # 9. refresh public db
        log("#{schema} refresh public db...")
        db_mgr.refresh_public_db(schema)

        # 10. create flat files
        log("#{schema} creating flat files...")
        begin
          create_flat_files
        rescue Exception => e
          Airbrake.notify(e)
        end
      end

      refresh_data_definitions

      # 11. change the state of the load event from “running” to “complete”
      @load_event.update({ status:'complete'})

      # 12. send email
      send_notification
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
      raise "Removing too many studies #{to_remove.count}" if  Study.count <= to_remove.count
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

    def update_study(nct_id)
      begin
        stime = Time.now
        record = StudyJsonRecord.find_by(nct_id: nct_id) || StudyJsonRecord.create(nct_id: nct_id, content: {})
        changed = record.update_from_api

        if record.blank? || record.content.blank?
          record.destroy
        else
          record.create_or_update_study
        end
      rescue => e
        ErrorLog.error(e)
        Airbrake.notify(e)
      end
      Time.now - stime
    end

    def remove_study(id)
      stime = Time.now
      study = Study.find_by(nct_id: id)
      study.remove_study_data if study
      Time.now - stime
    end

    def load_study(study_id)
      # 1. remove constraings
      log("#{schema} remove constraints...")
      db_mgr.remove_constraints
      update_study(study_id)
      # 2. add constraints
      log("#{schema} adding constraints...")
      db_mgr.add_constraints
    end

    def load_multiple_studies(string_nct_ids)
      # string_nct_ids looks like 'NCT00700336 NCT00772330 NCT00845871 NCT00852124 NCT01178814'
      # here I'm turning the string into an array
      array_nctids = string_nct_ids.split(' ')
      # 1. remove constraings
      log("#{schema} remove constraints...")
      db_mgr.remove_constraints
      array_nctids.each{|nctid|update_study(nctid)}
      # 2. add constraints
      log("#{schema} adding constraints...")
      db_mgr.add_constraints
    end

    def set_downcase_terms
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

    def refresh_data_definitions(data = Util::FileManager.new.default_data_definitions)
      return unless Admin::AdminBase.database_exists?

      log('refreshing data definitions...')
      Admin::DataDefinition.populate(data)
    end

    def take_snapshot
      log('dumping database...')
      db_mgr.dump_database

      log('creating zipfile of database...')
      Util::FileManager.new.save_static_copy
      rescue StandardError => e
        load_event.add_problem("#{e.message} (#{e.class} #{e.backtrace}")
    end

    def send_notification
      log('sending email notification...')
      Notifier.report_load_event(load_event)
    end

    def create_flat_files
      log('exporting tables as flat files...')
      Util::TableExporter.new([],'ctgov').run(delimiter: '|', should_archive: true)
    end

    def db_mgr
      @db_mgr ||= Util::DbManager.new(event: load_event)
    end
  end
end
