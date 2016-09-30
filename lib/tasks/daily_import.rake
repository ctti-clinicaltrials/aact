namespace :import do
  namespace :daily do
    task :run, [:days_back] => :environment do |t, args|
      if ![1].include? Date.today.day || args[:force]
        ClinicalTrials::Updater.new({:event_type=>'incremental',:days_back=>4}).run
        # Defaults: incremental & 4 days back, so simpler way is...
        # ClinicalTrials::Updater.new.run
      end
    end
  end
end
