namespace :alt_import do
  namespace :daily do
    task :run, [:days_back] => :environment do |t, args|
      ClinicalTrials::RssReader.new(days_back: 4).get_changed_nct_ids.each{|id|
        StudyUpdater.new.update_studies(nct_ids: [id])
      }
    end
  end
end
