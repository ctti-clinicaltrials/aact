namespace :stats do
  desc 'counts for all the tables'
  task :counts, [:schema] => :environment do |t, args|
    with_search_path(args[:schema]) do
      StudyRelationship.study_models.each do |model|
        printf("%-40s %s\n", model.name, model.count)
      end
    end
  end

  desc 'compare'
  task :compare => :environment do
    `rm -rf comprisons`
    `mkdir comparisons`
    StudyRelationship.study_models.each do |model|
      sql = <<-SQL
        SELECT
        original.nct_id
        FROM (
          SELECT
          nct_id,
          COUNT(*) AS count
          FROM ctgov.#{model.table_name}
          GROUP BY nct_id
        ) AS original
        LEFT JOIN (
          SELECT
          nct_id,
          COUNT(*) AS count
          FROM ctgov_v2.#{model.table_name}
          GROUP BY nct_id
        ) AS future ON future.nct_id = original.nct_id
        WHERE original.count != future.count OR future.count IS NULL
      SQL

      results = ActiveRecord::Base.connection.execute(sql)
      CSV.open("comparisons/#{model.table_name}.csv", "w") do |csv|
        # Write the header row (if your query has headers)
        csv << results.fields
      
        # Write each row from the query results
        results.each do |row|
          csv << row.values
        end
      end
      puts "#{model.table_name} #{results.count} differences"
    end
  end

  desc 'find missing studies'
  task :missing => :environment do
    sql = <<-SQL
      SELECT
      SJR.nct_id
      FROM study_json_records SJR
      LEFT JOIN ctgov_v2.studies S ON S.nct_id = SJR.nct_id
      WHERE S.nct_id IS NULL
    SQL
    results = ActiveRecord::Base.connection.execute(sql)
    results.each do |result|
      puts result['nct_id']
    end
  end

  desc 'compare studies'
  task :compare_studies, [:nct_id] => :environment do |t, args|
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
        puts "#{model.table_name}: #{original} vs #{future}"
      end
    end
  end

  desc 'show indexes and foreign keys'
  task :indexes, [:schema] => :environment do |t, args|
    with_search_path(args[:schema]) do
      StudyRelationship.study_models.each do |model|
        puts model.table_name.blue
        #model.connection.indexes(model.table_name)
        model.connection.foreign_keys(model.table_name).each do |fk|
          puts "  #{fk.column} -> #{fk.to_table}.#{fk.primary_key}"
        end
      end
    end
  end
end