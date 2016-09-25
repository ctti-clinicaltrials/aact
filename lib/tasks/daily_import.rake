namespace :import do
  namespace :daily do
    task :run, [:days_back] => :environment do |t, args|
      if ![1].include? Date.today.day || args[:force]
        ClinicalTrials::Updater.new.incremental(args)
      end
    end
  end
end
