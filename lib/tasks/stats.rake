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
    StudyRelationship.study_models.each do |model|
      sql = <<-SQL
        SELECT
        nct_id
        FROM (
          SELECT
          nct_id,
          COUNT(*) AS count
          FROM ctgov.#{table_name}
        ) AS original
        JOIN (
          SELECT
          nct_id,
          COUNT(*) AS count
          FROM ctgov_v2.#{table_name}
        ) AS future ON future.nct_id = original.nct_id
        WHERE orignal.count != future.count
      SQL

      results = ActiveRecord::Base.connection.execute(sql)
      puts results.to_a
    end
  end
end