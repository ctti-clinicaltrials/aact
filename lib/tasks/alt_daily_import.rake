namespace :alt_import do
  namespace :daily do
    task :run, [:days_back] => :environment do |t, args|
      ClinicalTrials::RssReader.new(days_back: args[:days_back]).get_changed_nct_ids.each{|id|
        StudyUpdater.new.update_studies([id])
      }
    end
  end
end
