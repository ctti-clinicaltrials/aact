module Util
  class UpdaterV2

    attr_reader :params, :schema

    def initialize(params = {})
      @params = params # #<Rake::TaskArguments schema: ctgov_v2>
      @type = (params[:event_type] || "incremental")
      @schema = params[:schema] || "ctgov_v2"
    end


    def execute
      log("EXECUTE V2 started")

      @load_event = Support::LoadEvent.create({ event_type: @type, status: 'running', description: '', problems: '' })

      ActiveRecord::Base.logger = nil # why are we disabling logger here?

      # 1. remove constraings
      log("v2: removing constraints...")
      db_mgr.remove_constraints
      @load_event.log("1/11 removed constraints")


      # 2. update studies
      log("v2: updating studies...")
      update_studies
      @load_event.log("2/11 updated studies")


      # 3. add constraints
      log("v2: adding constraints...")
      db_mgr.add_constraints
      @load_event.log("3/11 added constraints")


    end


    def update_studies

      to_update = StudyDownloader.download_recently_updated

      log("updating #{to_update.length} studies")

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
    end

    def remove_studies
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


    def update_study(nct_id)
      stime = Time.now
      record = StudyDownloader.download([nct_id]) # StudyJsonRecord.find_by(nct_id: nct_id) || StudyJsonRecord.create(nct_id: nct_id, content: {})
    #   changed = record.update_from_api unless ENV['STUDY_SECTIONS'] # what's the purpose of this condition?
      if record.blank? || record.content.blank?
        record.destroy
      else
        StudyJsonRecord::Worker.new.process # record.create_or_update_study
      end

    Time.now - stime
    rescue => e
      # Airbrake.notify(e) # is it working in local env?
      puts "An error occurred: #{e.message}"
    end


    # permanently remove study info from ctgov_v2 schema and study_json_records table
    def remove_study(id)
      stime = Time.now

      study = Study.find_by(nct_id: id)
      study.remove_study_data if study
      
      record = record = StudyJsonRecord.find_by(nct_id: id, version: '2')
      record.destroy if record

      return Time.now - stime
    end


    private

    def db_mgr
      # do we need to create new instance of DbManager every time?
      Util::DbManager.new(event: @load_event, schema: @schema)
    end

    def log(msg)
      puts "#{Time.zone.now}: #{msg}"
    end

    def htime(seconds)
      seconds = seconds.to_i
      hours = seconds / 3600
      seconds -= hours * 3600
      minutes = seconds / 60
      seconds -= minutes * 60
      "#{hours}:#{'%02i' % minutes}:#{'%02i' % seconds}"
    end

  end
end
