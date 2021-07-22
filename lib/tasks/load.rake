namespace :db do

  desc "Load the AACT database from ClinicalTrials.gov"
  task :load, [:days_back, :event_type, :full_featured] => :environment do |t, args|
    # The updater will default the params to run a relativey quick load:
    # incremental, not full featured, just a couple days
    Util::Updater.new(args).run
  end

  task :beta_load, [:days_back, :event_type, :full_featured] => :environment do |t, args|
    `bundle exec rake log:clear`
    updater = Util::Updater.new(args.to_h.merge(schema: 'beta'))
    updater.execute
    # puts StudyJsonRecord.comparison
  end

  task :both_load, [:days_back, :event_type, :full_featured] => :environment do |t, args|
    `bundle exec rake log:clear`
    updater = Util::Updater.new(schema: 'normal')
    updater.execute

    updater = Util::Updater.new(schema: 'beta')
    updater.execute
  end

  task :loop do 
    loop do
      if Time.now.hour == 4
        updater = Util::Updater.new(schema: 'normal')
        updater.execute

        updater = Util::Updater.new(schema: 'beta')
        updater.execute
      end
      sleep 60
    end
  end

  task :load2, [:schema, :search_days_back] => :environment do |t, args|
    Util::Updater.new(args).execute
  end

  task :restore_from_file, [:path_to_file, :database_name] => :environment do |t, args|
    Util::DbManager.new.restore_from_file(args)
  end
  
  task :restore_from_url, [:url, :database_name] => :environment do |t, args|
    Util::DbManager.new.restore_from_url(args)
  end
end
