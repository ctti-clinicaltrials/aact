namespace :db do

  desc "Load the AACT database from ClinicalTrials.gov"
  task :run, [] => :environment do |t, args|
    Util::Updater.new(args).run_main_loop
  end

  task :execute, [:schema, :search_days_back] => :environment do |t, args|
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
