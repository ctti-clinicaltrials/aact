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
    con.execute("CREATE SCHEMA ctgov;")
    con.execute("CREATE SCHEMA support;")
    con.execute("GRANT ALL ON ALL TABLES IN SCHEMA ctgov TO #{aact_superuser};")
    con.execute("GRANT ALL ON ALL TABLES IN SCHEMA support TO #{aact_superuser};")
    con.execute("ALTER ROLE #{aact_superuser} WITH CREATEROLE;")
    con.execute("ALTER ROLE #{aact_superuser} IN DATABASE #{aact_back_db} SET SEARCH_PATH TO ctgov, support, public;")
  end

  task copy_schema_to_beta: [:environment] do
    ActiveRecord::Base.connection.execute("CREATE SCHEMA IF NOT EXISTS ctgov;")
    aact_superuser = ENV['AACT_DB_SUPER_USERNAME'] || 'aact'
    aact_back_db = ENV['AACT_BACK_DATABASE_NAME'] || 'aact'
    `pg_dump -U #{aact_superuser} --schema='ctgov' --schema-only #{aact_back_db} | sed 's/ctgov/ctgov_beta/g' | psql -U #{aact_superuser} -d #{aact_back_db}`
  end

end
