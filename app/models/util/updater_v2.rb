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
      log("v2 removing constraints...")
      db_mgr.remove_constraints
      @load_event.log("1/11 removed constraints")


    end


    def current_study_differences
      api_studies = ClinicalTrialsApiV2.all
      result = ActiveRecord::Base.connection.execute("SELECT nct_id, last_update_posted_date FROM ctgov_v2.studies")
      puts "aact study count: #{result.count}"
      puts "ctgov study count: #{api_studies.count}"
      current_studies = Hash[result.map { |record| [record['nct_id'], record['last_update_posted_date']] }]
      studies_to_update = api_studies.select do |api_study|
        current_study_update_date = current_studies[api_study[:nct_id]]
        current_study_update_date.nil? || Date.parse(api_study[:updated]) > Date.parse(current_study_update_date)
      end.map { |study| study[:nct_id] }

      # TODO: add time calculations to see how effiecient Set are
      studies_to_remove = current_studies.keys.to_set - api_studies.map { |study| study[:nct_id] }.to_set
      puts "update: #{studies_to_update.take(10)}"
      puts "remove: #{studies_to_remove.take(10)}"
      puts "result: #{result.take(10)}"
      return [api_studies, studies_to_update, studies_to_remove]
    rescue => e
      puts "An error occurred: #{e.message}"
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


    private

    def db_mgr
      # do we need to create new instance of DbManager every time?
      Util::DbManager.new(event: @load_event, schema: @schema)
    end

    def log(msg)
      puts "#{Time.zone.now}: #{msg}"
    end

  end
end
