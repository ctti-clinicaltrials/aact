require 'roo'
require 'csv'

namespace :db do

  task drop: [:environment] do
    if ENV['RAILS_ENV'] == 'test'
      begin
        ActiveRecord::Base.connection.execute('DROP DATABASE aact_pub_test');
      rescue
      end
      begin
      ActiveRecord::Base.connection.execute('DROP DATABASE aact_alt_test');
      rescue
      end
    end
  end

  task create: [:environment] do
    aact_superuser = ENV['AACT_DB_SUPER_USERNAME'] || 'aact'
    if ENV['RAILS_ENV'] == 'test'
      aact_back_db = 'aact_test'
      begin
        ActiveRecord::Base.connection.execute('CREATE DATABASE aact_pub_test');
      rescue
      end
      begin
        ActiveRecord::Base.connection.execute('CREATE DATABASE aact_alt_test');
      rescue
      end
    else
      aact_back_db = ENV['AACT_BACK_DATABASE_NAME'] || 'aact'
    end
    Rake::Task["db:create"].invoke
    con=ActiveRecord::Base.connection
    con.execute("CREATE SCHEMA IF NOT EXISTS ctgov;")
    con.execute("CREATE SCHEMA IF NOT EXISTS support;")
    con.execute("CREATE SCHEMA IF NOT EXISTS ctgov_beta;")
    con.execute("GRANT ALL ON ALL TABLES IN SCHEMA ctgov_beta TO #{aact_superuser};")
    con.execute("GRANT ALL ON ALL TABLES IN SCHEMA ctgov TO #{aact_superuser};")
    con.execute("GRANT ALL ON ALL TABLES IN SCHEMA support TO #{aact_superuser};")
    con.execute("ALTER ROLE #{aact_superuser} WITH CREATEROLE;")
    con.execute("ALTER ROLE #{aact_superuser} IN DATABASE #{aact_back_db} SET SEARCH_PATH TO ctgov, support, public, ctgov_beta;")
  end

  task single_row_comparison: [:environment] do
    # hardcoded table names with one row per study from excel file
    file_table_names=['brief_summaries', 'calculated_values', 'categories',
                      'designs', 'detailed_descriptions', 'eligibilities',
                      'participant_flows', 'studies']

    # finds table_names and their columns according to list in the file_table_names
    sql = "SELECT t.table_name,
                  c.column_name
           FROM information_schema.tables AS t
           INNER JOIN information_schema.columns AS c on c.table_name = t.table_name
                                                  AND c.table_schema = t.table_schema
           WHERE t.table_schema= 'ctgov' AND c.table_name IN (#{file_table_names.map { |e| "'#{e}'" }.join(', ')});"
    all_columns = ActiveRecord::Base.connection.execute(sql).to_a

    # comparing data in each column and adding it to a csv file if there's data mismatching
    all_columns.each do |column|
      if column['column_name'].in?(["id", "created_at", "updated_at"])
        next
      else
        query = "SELECT T.nct_id,
                        T.#{column["column_name"]} as ctgov_#{column["column_name"]},
                        BT.#{column["column_name"]} as ctgov_beta_#{column["column_name"]}
                FROM ctgov.#{column["table_name"]} T
                JOIN ctgov_beta.#{column["table_name"]} BT ON T.nct_id = BT.nct_id
                WHERE T.#{column["column_name"]} != BT.#{column["column_name"]}
                OR (T.#{column["column_name"]} IS NOT NULL AND BT.#{column["column_name"]} IS NULL)
                OR (T.#{column["column_name"]} IS NULL AND BT.#{column["column_name"]} IS NOT NULL);"
        result =ActiveRecord::Base.connection.execute(query).to_a
        if result.count > 0
          file = "#{Util::FileManager.new.beta_differences_directory}/#{column['table_name']}-#{column["column_name"]}.csv"
          headers = ['nct_id', 'ctgov column', 'ctgov_beta column']
          CSV.open(file, 'w', write_headers: true, headers: headers) do |writer|
            writer << result[0].values
          end
        end
      end
    end
  end

  task rename_columns: [:environment] do

    sql_one= "SELECT t.table_schema,
                t.table_name,
	              c.column_name
              FROM information_schema.tables t
              INNER JOIN information_schema.columns AS c on c.table_name = t.table_name
                                AND c.table_schema = t.table_schema
              WHERE c.column_name = 'ctgov_beta_group_code' AND t.table_schema= 'ctgov_beta'";

    find_columns= ActiveRecord::Base.connection.execute(sql_one).to_a

    find_columns.each do|r|
      sql_two= "ALTER TABLE #{r['table_schema']}.#{r['table_name']} RENAME COLUMN ctgov_beta_group_code TO ctgov_group_code;"
      ActiveRecord::Base.connection.execute(sql_two)
    end
  end

  task copy_schema: [:environment] do
    aact_superuser = ENV['AACT_DB_SUPER_USERNAME'] || 'aact'
    if ENV['RAILS_ENV'] == 'test'
      aact_back_db = 'aact_test'
    else
      aact_back_db = ENV['AACT_BACK_DATABASE_NAME'] || 'aact'
    end
    extra = "-h #{ENV['AACT_HOST'] || 'localhost'} -p #{ENV['AACT_PORT'] || '5432'}"
    puts "pg_dump -U #{aact_superuser} --schema='ctgov' --schema-only #{aact_back_db} #{extra} | sed 's/ctgov/ctgov_beta/g; s/ctgov_beta_group_code/ctgov_group_code/g' | psql -U #{aact_superuser} -d #{aact_back_db} #{extra}"
    `pg_dump -U #{aact_superuser} --schema='ctgov' --schema-only #{aact_back_db} #{extra} | sed 's/ctgov/ctgov_beta/g; s/ctgov_beta_group_code/ctgov_group_code/g' | psql -U #{aact_superuser} -d #{aact_back_db} #{extra}`
  end
end
