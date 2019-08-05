namespace :db do

  task create: [:environment] do
    Rake::Task["db:create"].invoke
    aact_back_db = ENV['AACT_BACK_DATABASE_NAME'] || 'aact_back'
    con=ActiveRecord::Base.establish_connection(aact_back_db).connection
    con.execute("CREATE SCHEMA ctgov;")
    con.execute("CREATE SCHEMA support;")
    con.execute("ALTER ROLE #{aact_superuser} IN DATABASE #{aact_back_db} SET SEARCH_PATH TO ctgov, support, public;")
  end
end

