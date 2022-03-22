namespace :db do

  desc "Load the AACT database from ClinicalTrials.gov"
  task :load, [:days_back, :event_type, :full_featured] => :environment do |t, args|
    # The updater will default the params to run a relativey quick load:
    # incremental, not full featured, just a couple days
    Util::Updater.new(args).run
  end

  task :load2, [:schema, :search_days_back] => :environment do |t, args|
    Util::Updater.new(args).execute
  end

  task :restore_from_file, [:path_to_file, :database] => :environment do |t, args|
    Util::DbManager.new.restore_from_file(args)
  end

  desc 'load database into a specific database from a url'
  task :restore_from_url, [:url, :database_name] => :environment do |t, args|
    Util::DbManager.new.restore_from_url(args)
  end

  desc 'update a single nct id'
  task :load_study, [:nct_id] => :environment do |t, args|
    Util::Updater.new.load_study(args[:nct_id])
  end

  desc 'update a multiple nct ids'
  task :load_multiple_studies, [:nct_id] => :environment do |t, args|
    Util::Updater.new.load_multiple_studies(args[:nct_id])
  end
end
