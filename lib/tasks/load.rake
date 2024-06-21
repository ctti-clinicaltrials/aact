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
  task :import_study, [:nct_id] => :environment do |t, args|
    worker = StudyJsonRecord::Worker.new
    records = StudyJsonRecord.where(nct_id: args[:nct_id], version: '2')
    worker.process(1, records)
  end

  desc 'process study json records'
  task :import, [:schema] => :environment do |t, args|
    with_search_path(args[:schema]) do
      StudyJsonRecord::Worker.new.import_all(5000)
    end
  end

  desc 'import both, imports studies using both api versions'
  task :import_both, [:nct_id] => :environment do |t, args|
    # download both
    StudyDownloader.download([args[:nct_id]], '1')
    StudyDownloader.download([args[:nct_id]], '2')

    # # import v1
    record = StudyJsonRecord.find_by(nct_id: args[:nct_id], version: '1')
    record.create_or_update_study

    # # import v2
    worker = StudyJsonRecord::Worker.new
    records = StudyJsonRecord.where(nct_id: args[:nct_id], version: '2')
    worker.process(1, records)

    # compare the two
    StudyRelationship.study_models.each do |model|
      sql = <<-SQL
        SELECT
        COUNT(*)
        FROM ctgov.#{model.table_name}
        WHERE nct_id = '#{args[:nct_id]}'
      SQL
      original = ActiveRecord::Base.connection.execute(sql).to_a.first.dig('count')

      sql = <<-SQL
        SELECT
        COUNT(*)
        FROM ctgov_v2.#{model.table_name}
        WHERE nct_id = '#{args[:nct_id]}'
      SQL
      future = ActiveRecord::Base.connection.execute(sql).to_a.first.dig('count')
      if original != future
        puts "#{model.table_name}: v1: #{original}  v2: #{future}"
      end
    end
  end


  desc "Load the AACT database from ClinicalTrials.gov"

  # TODO: remove or refactor after finalizing the UpdaterV2
  # task :run, [:schema] => :environment do |t, args|
  #   if args[:schema] == 'ctgov_v2'
  #     Util::UpdaterV2.new(args).run_main_loop
  #   else
  #     Util::Updater.new(args).run_main_loop
  #   end
  # end

  # task :execute, [:schema, :search_days_back] => :environment do |t, args|
  #   if args[:schema] == 'ctgov_v2'
  #     Util::UpdaterV2.new(args).execute
  #   else
  #     Util::Updater.new(args).execute
  #   end
  # end

  # Run the UpdaterV2 only with optional schema argument
  task :run_updater, [:schema] => :environment do |t, args|
    Util::UpdaterV2.new(args).execute
  end

  task :run_main_loop, [:schema] => :environment do |t, args|
    Util::UpdaterV2.new(args).run_main_loop
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

  desc 'drop all entries for a model and reimport it'
  task :import_model, [:model] => :environment do |t, args|
    with_search_path('ctgov_v2, support, public') do
      model = args[:model].classify.constantize
      model.delete_all

      worker = StudyJsonRecord::Worker.new
      mappings = StudyRelationship.sorted_mapping.select{|k| k[:table] == args[:model].to_sym }
      puts mappings.inspect
      StudyJsonRecord.where(version: '2').find_in_batches(batch_size: 5000) do |records|
        puts records.length
        mappings.each do |mapping|
          worker.process_mapping(mapping, records)
        end
      end
    end
  end

  desc 'add indexes to the database'
  task :add_indexes, [:schema] => :environment do |t, args|
    with_search_path(args[:schema]) do
      db = Util::DbManager.new
      db.add_indexes
    end
  end
end
