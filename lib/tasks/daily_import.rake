namespace :import do
  namespace :daily do
    task :run, [:days_back] => :environment do |t, args|
      ClinicalTrials::Updater.new.incremental(args)
    end
  end
end
