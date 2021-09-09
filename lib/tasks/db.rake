require 'roo'

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
    workbook = Roo::Spreadsheet.open 'https://aact.ctti-clinicaltrials.org/static/documentation/aact_tables.xlsx'
    file_table_names=[]
    for i in (2..45) do
      file_table_names << workbook.cell(i, 2)
    end
    puts file_table_names

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
