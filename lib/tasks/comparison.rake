namespace :compare do
  task :v2, [:nct_id] => :environment do |t, args|
    VersionComparator.check(args[:nct_id])
  end

  task :v2_model, [:nct_id, :model] => :environment do |t, args|
    VersionComparator.check_model(args[:nct_id], args[:model].to_sym)
  end

  task :full, [:model] => :environment do |t, args|
    VersionComparator.full_check(args[:model])
  end

  task :nct_ids, [:first_schema,:second_schema] => :environment do |t, args|
    StudyJsonRecord.data_verification_csv(args)
  end

  desc 'get the difference between our database and the Clinical Trials Study Statistics API endpoint'
  task :study_statistics, [:schema]  => :environment do |t, args|
    Verifier.refresh(args)
  end

  task :single_rows, [:first_schema,:second_schema] => :environment do |t, args|
    first_schema = args[:first_schema]
    second_schema = args[:second_schema]
    # hardcoded table names with one row per study from excel file
    file_table_names=['brief_summaries', 'calculated_values', 'search_results',
                      'designs', 'detailed_descriptions', 'eligibilities',
                      'participant_flows', 'studies']

    # finds table_names and their columns according to list in the file_table_names
    sql = "SELECT t.table_name,
                  c.column_name
           FROM information_schema.tables AS t
           INNER JOIN information_schema.columns AS c on c.table_name = t.table_name
                                                  AND c.table_schema = t.table_schema
           WHERE t.table_schema= '#{second_schema}' AND c.table_name IN (#{file_table_names.map { |e| "'#{e}'" }.join(', ')});"
    all_columns = ActiveRecord::Base.connection.execute(sql).to_a

    # comparing data in each column and adding it to a csv file if there's data mismatching
    all_columns.each do |column|
      if column['column_name'].in?(["id", "created_at", "updated_at"])
        next
      else
        query = "SELECT T.nct_id,
                        T.#{column["column_name"]} as #{second_schema}_#{column["column_name"]},
                        BT.#{column["column_name"]} as #{first_schema}_#{column["column_name"]}
                FROM #{second_schema}.#{column["table_name"]} T
                JOIN #{first_schema}.#{column["table_name"]} BT ON T.nct_id = BT.nct_id
                WHERE T.#{column["column_name"]} != BT.#{column["column_name"]}
                OR (T.#{column["column_name"]} IS NOT NULL AND BT.#{column["column_name"]} IS NULL)
                OR (T.#{column["column_name"]} IS NULL AND BT.#{column["column_name"]} IS NOT NULL);"
        result =ActiveRecord::Base.connection.execute(query).to_a
        if result.count > 0
          file = "#{Util::FileManager.new.differences_directory}/#{column['table_name']}-#{column["column_name"]}.csv"
          headers = ['nct_id', "#{second_schema} column", "#{first_schema} column"]
          CSV.open(file, 'w', write_headers: true, headers: headers) do |writer|
            writer << result[0].values
          end
        end
      end
    end
  end
end
