namespace :db do
  desc 'Clear study data from the database'
  task :clear, [:schema] => :environment do |t, args|
    with_search_path(args[:schema]) do
      StudyRelationship.study_models.each do |model|
        model.delete_all
      end
    end
  end

  desc 'process study json records'
  task :import, [:schema] => :environment do |t, args|
    with_search_path(args[:schema]) do
      StudyJsonRecord::Worker.new.import_all(5000)
    end
  end

  desc "Load the AACT database from ClinicalTrials.gov"
  task :run, [:schema] => :environment do |t, args|
    if args[:schema] == 'ctgov_v2'
      Util::UpdaterV2.new(args).run_main_loop
    else
      Util::Updater.new(args).run_main_loop
    end
  end

  task :execute, [:schema, :search_days_back] => :environment do |t, args|
    if args[:schema] == 'ctgov_v2'
      Util::UpdaterV2.new(args).execute
    else
      Util::Updater.new(args).execute
    end
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

  desc 'load a set of 100 studies'
  task :sample_studies, [] => :environment do |t, args|
    studies = File.read('sample-studies')
    Util::Updater.new.load_multiple_studies(studies)
  end
end
