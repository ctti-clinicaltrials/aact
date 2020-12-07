namespace :db do

  desc "Load the AACT database from ClinicalTrials.gov"
  task :load, [:days_back, :event_type, :full_featured] => :environment do |t, args|
    # The updater will default the params to run a relativey quick load:
    # incremental, not full featured, just a couple days
    Util::Updater.new(args).run
  end
end
