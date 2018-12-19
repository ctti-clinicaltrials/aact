namespace :db do

  task create: [:environment] do
    Rake::Task["db:create"].invoke
    con=ActiveRecord::Base.connection
    con.execute("CREATE SCHEMA ctgov;")
    con.execute("CREATE SCHEMA support;")
    con.execute("ALTER ROLE #{ENV['AACT_DB_SUPER_USERNAME']} IN DATABASE #{ENV['AACT_BACK_DATABASE']} SET SEARCH_PATH TO ctgov, support, public;")
    con.reset!
  end
end

