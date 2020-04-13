namespace :db do

  desc "Load the AACT database from ClinicalTrials.gov"
  task :load, [:days_back, :event_type, :full_featured] => :environment do |t, args|
    # The updater will default the params to run a relativey quick load:
    # incremental, not full featured, just a couple days
    Util::Updater.new(args).run
  end
  task :beta_load, [:days_back, :event_type, :full_featured] => :environment do |t, args|
    StudyJsonRecord.too_long
    # StudyJsonRecord.run(args)
  end
  task :both_load, [:days_back, :event_type, :full_featured] => :environment do |t, args|
    Util::Updater.new(args).run
    StudyJsonRecord.run(args)
  end
end
