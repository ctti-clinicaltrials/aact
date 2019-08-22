namespace :db do

  task create: [:environment] do
    Rake::Task["db:create"].invoke
    aact_superuser = ENV['AACT_DB_SUPER_USERNAME'] || 'aact'
    aact_back_db = ENV['AACT_BACK_DATABASE_NAME'] || 'aact'
    con=ActiveRecord::Base.connection
    con.execute("CREATE SCHEMA ctgov;")
    con.execute("CREATE SCHEMA support;")
    con.execute("GRANT ALL ON ALL TABLES IN SCHEMA ctgov TO #{aact_superuser};")
    con.execute("GRANT ALL ON ALL TABLES IN SCHEMA support TO #{aact_superuser};")
    con.execute("ALTER ROLE #{aact_superuser} WITH CREATEROLE;")
    con.execute("ALTER ROLE #{aact_superuser} IN DATABASE #{aact_back_db} SET SEARCH_PATH TO ctgov, support, public;")
  end

end
