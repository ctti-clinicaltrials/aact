namespace :db do

  desc "Load the AACT database from ClinicalTrials.gov"
  task :load, [:days_back, :event_type, :full_featured] => :environment do |t, args|
    # The updater will default the params to run a relativey quick load:
    # incremental, not full featured, just a couple days
    Util::Updater.new(args).run
  end
  task :beta_load, [:days_back, :event_type, :full_featured] => :environment do |t, args|
    `bundle exec rake log:clear`
    StudyJsonRecord.run(args)
    puts StudyJsonRecord.comparison
  end
  task :both_load, [:days_back, :event_type, :full_featured] => :environment do |t, args|
    `bundle exec rake log:clear`
    Util::Updater.new(args).run
    StudyJsonRecord.run(args)
    puts StudyJsonRecord.comparison
  end
  task :restore_from_file, [:path_to_file, :database_name] => :environment do |t, args|
    Util::DbManager.new.restore_from_file(args)
  end
  task :restore_from_url, [:url] => :environment do |t, args|
    Util::DbManager.new.restore_from_url(args)
  end
end
