namespace :db do

  desc "Load the AACT database from ClinicalTrials.gov"
  task :load, [:days_back, :event_type, :full_featured, :schema] => :environment do |t, args|
    schema = args[:schema] || 'ctgov'
    Util::Updater.const_set('SCHEMA', schema)
    # The updater will default the params to run a relativey quick load:
    # incremental, not full featured, just a couple days
    puts "running #{args}"
    schema == 'ctgov' ? Util::Updater.new(args).run : StudyJsonRecord.run(args)
  end
end
