namespace :import do
  desc 'import single study'

  desc 'import studies in a file'
  task :file, [:file] => :environment do |t, args|
    lines = File.readlines(args[:file])
    ids = lines.select{|k| k =~ /nct\d+/i }
    ids = ids.map{|k| k.strip }
    puts "importing #{ids.length} studies"

    ids.each do |nct_id|

      # download both
      StudyDownloader.download([nct_id], '1')
      StudyDownloader.download([nct_id], '2')

      # # import v1
      record = StudyJsonRecord.find_by(nct_id: nct_id, version: '1')
      record.create_or_update_study

      # # import v2
      worker = StudyJsonRecord::Worker.new
      records = StudyJsonRecord.where(nct_id: nct_id, version: '2')
      worker.process(1, records)
    end
  end

  desc 'import missing v1 given v2'
  task :missing_v1, [:nct_id] => :environment do |t, args|
    v1 = Study.pluck(:nct_id)
    v2 = []
    with_search_path('ctgov_v2') do
      v2 = Study.pluck(:nct_id)
    end

    missing = v2 - v1
    missing.each do |nct_id|
      StudyDownloader.download([nct_id], '1')
      record = StudyJsonRecord.find_by(nct_id: nct_id, version: '1')
      record.create_or_update_study
    end
  end

  desc 'import both, imports studies using both api versions'
  task :both, [:nct_id] => :environment do |t, args|
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
end