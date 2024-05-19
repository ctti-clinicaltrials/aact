module Util
  class UpdaterV2 < Updater
    
    # TODO: when all logic is moved to UpdaterV2, refactor this method - to many responsibilities
    # TODO: add tests for refactored method
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


    # TODO: current remove study method works with ctgov schema, not ctgov_v2
  end
end
