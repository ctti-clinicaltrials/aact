module Util
  class UpdaterV2 < Updater
    
    # TODO: when all logic is moved to UpdaterV2, refactor this method - to many responsibilities
    # TODO: add tests for refactored method
    def current_study_differences
      api_studies = ClinicalTrialsApiV2.all
      puts "aact  study count: #{Study.count}"
      puts "ctgov study count: #{api_studies.count}"

      current_studies = Hash[Study.pluck(:nct_id, :last_update_posted_date)]

      studies_to_update = api_studies.select do |api_study|
        current_study_update_date = current_studies[api_study[:nct_id]]
        current_study_update_date.nil? || Date.parse(api_study[:updated]) > current_study_update_date
      end.map { |study| study[:nct_id] }

      # TODO: add time calculations to see how effiecient Set are
      studies_to_remove = current_studies.keys.to_set - api_studies.map { |study| study[:nct_id] }.to_set
      puts "update: #{studies_to_update.take(10)}"
      puts "remove: #{studies_to_remove.take(10)}"
      byebug
      return [api_studies, studies_to_update, studies_to_remove]
    end

  end
end
