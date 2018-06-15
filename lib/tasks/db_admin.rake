task spec: ['admin:db:test:prepare']
namespace :admin do
  namespace :db do |ns|

    desc 'Do not drop the AACT database - only the support schema'
    task drop: [:environment] do
      puts "Dropping schema support..."
      con = ActiveRecord::Base.connection
      con.execute('DROP SCHEMA IF EXISTS support CASCADE;')
      con.execute("alter role ctti set search_path to ctgov, public;")
      con.reset!
    end

    desc 'Do not create the AACT database; only the support schema'
    task create: [:environment] do
      puts "Creating schema support..."
      con = ActiveRecord::Base.connection
      con.execute('CREATE SCHEMA IF NOT EXISTS support;')
      con.execute("alter role ctti set search_path to ctgov, support, public;")
      con.execute("grant usage on schema support to ctti;")
      con.execute("grant create on schema support to ctti;")
      con.reset!
    end

    task migrate: [:environment] do
      # make rails unaware of other schemas. If rails detects an existing schema_migrations table,
      # it will use it - but we need a support schema_migrations table in our support schema
      con = ActiveRecord::Base.connection
      con.execute("alter role ctti set search_path to support;")
      con.reset!
      Rake::Task["db:migrate"].invoke
      # now put ctgov & public schemas back in the searh path
      con = ActiveRecord::Base.connection
      con.execute("alter role ctti set search_path to ctgov, support, public;")
      con.reset!
    end

    task rollback: [:environment] do
      # make rails unaware of any other schema in the database
      con=ActiveRecord::Base.connection
      con.execute("alter role ctti set search_path to support;")
      con.reset!
      Rake::Task["db:rollback"].invoke
      # now put ctgov & public schemas back in the searh path
      con = ActiveRecord::Base.connection
      con.execute("alter role ctti set search_path to ctgov, support, public;")
      con.reset!
    end

    task :seed do
      Rake::Task["db:seed"].invoke
    end

    task :version do
      Rake::Task["db:version"].invoke
    end

    namespace :schema do
      task :load do
        Rake::Task["db:schema:load"].invoke
      end

      task :dump do
        Rake::Task["db:schema:dump"].invoke
      end
    end

    namespace :test do
      task :prepare do
        Rake::Task["db:test:prepare"].invoke
      end
    end

    # append and prepend proper tasks to all the tasks defined here above
    ns.tasks.each do |task|
      task.enhance ["admin:set_custom_config"] do
        Rake::Task["admin:revert_to_original_config"].invoke
      end
    end
  end

  task :set_custom_config do
    # save current vars
    @original_config = {
      env_schema: ENV['SCHEMA'],
      config: Rails.application.config.dup
    }

    # set config variables for support schema
    ENV['SCHEMA'] = "db_admin/structure.sql"
    Rails.application.config.paths['db'] = ["db_admin"]
    Rails.application.config.paths['db/migrate'] = ["db_admin/migrate"]
    Rails.application.config.paths['db/seeds'] = ["db_admin/seeds.rb"]
    Rails.application.config.paths['config/database'] = ["config/database.yml"]
  end

  task :revert_to_original_config do
    # reset config variables to original values
    ENV['SCHEMA'] = @original_config[:env_schema]
    Rails.application.config = @original_config[:config]
  end

end
