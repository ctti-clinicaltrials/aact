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
      next if results.count == 0

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

  desc 'compare model for one study'
  task :compare_model, [:nct_id, :model] => :environment do |t, args|
    model = args[:model].classify.constantize
    v1 = model.where(nct_id: args[:nct_id])
  end

  desc 'compare unique'
  task :compare_unique => :environment do
    StudyRelationship.study_models.each do |model|
      # for each model itereate through the columns and check number of unique values
      model.attribute_names.each do |attribute|
        sql = <<-SQL
          SELECT
          COUNT(DISTINCT #{attribute})
          FROM ctgov.#{model.table_name}
        SQL
        original = ActiveRecord::Base.connection.execute(sql).to_a.first.dig('count')

        sql = <<-SQL
          SELECT
          COUNT(DISTINCT #{attribute})
          FROM ctgov_v2.#{model.table_name}
        SQL
        future = ActiveRecord::Base.connection.execute(sql).to_a.first.dig('count')
        if original > future
          puts "#{model.table_name}.#{attribute}: #{original} vs #{future}".red
        elsif original < future
          puts "#{model.table_name}.#{attribute}: #{original} vs #{future}".green
        end
      end
    end
  end

  desc 'compare values'
  task :compare_values, [:model, :column] => :environment do |t, args|
    sql = <<-SQL
      SELECT
      #{args[:model]}.#{args[:column]}
      FROM ctgov.#{args[:model]}
      EXCEPT
      SELECT
      #{args[:model]}.#{args[:column]}
      FROM ctgov_v2.#{args[:model]}
    SQL
    out = ActiveRecord::Base.connection.execute(sql).to_a
    puts out.inspect
  end
end