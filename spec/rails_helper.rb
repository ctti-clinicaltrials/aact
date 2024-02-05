ENV["RACK_ENV"] = "test"
ENV["RAILS_ENV"] = "test"

require File.expand_path("../../config/environment", __FILE__)

#  Define databases...
#abort("AACT_DB_SUPER_USERNAME env var must be set")   if !ENV["AACT_DB_SUPER_USERNAME"]

#  Define info needed to deploy code to a servers with Capistrano
#abort("GEM_HOME env var must be set for capistrano to deploy code to a server")              if !ENV["GEM_HOME"]
#abort("AACT_GEM_PATH env var must be set for capistrano to deploy code to a server")         if !ENV["AACT_GEM_PATH"]
#abort("AACT_PATH env var must be set for capistrano to deploy code to a server")             if !ENV["AACT_PATH"]
#abort("AACT_LD_LIBRARY_PATH env var must be set for capistrano to deploy code to a server")  if !ENV["AACT_LD_LIBRARY_PATH"]
#abort("AACT_DEPLOY_TO env var must be set for capistrano to deploy code to a server")        if !ENV["AACT_DEPLOY_TO"]
#abort("AACT_DEV_PUBLIC_HOSTNAME env var must be set for capistrano to deploy code to a server")  if !ENV["AACT_DEV_PUBLIC_HOSTNAME"]
#abort("AACT_DEV_REPO_URL env var must be set for capistrano to deploy code to a server")     if !ENV["AACT_DEV_REPO_URL"]
#abort("AACT_DEV_SERVER env var must be set for capistrano to deploy code to a server")       if !ENV["AACT_DEV_SERVER"]
#abort("AACT_SSH_KEY_DIR env var must be set for capistrano to deploy code to a server")      if !ENV["AACT_SSH_KEY_DIR"]
#abort("AACT_PROD_REPO_URL env var must be set for capistrano to deploy code to a server")    if !ENV["AACT_PROD_REPO_URL"]
#abort("AACT_PROD_SERVER env var must be set for capistrano to deploy code to a server")      if !ENV["AACT_PROD_SERVER"]
#abort("AACT_SERVER_USERNAME env var must be set for capistrano to deploy code to a server")  if !ENV["AACT_SERVER_USERNAME"]

#  Define contact info...
#abort("AACT_ADMIN_EMAILS env var must be set to email people administering AACT")            if !ENV["AACT_ADMIN_EMAILS"]
#abort("AACT_OWNER_EMAIL env var must be set to send emails")                                 if !ENV["AACT_OWNER_EMAIL"]

require "rspec/rails"

Dir[Rails.root.join("spec/support/**/*.rb")].sort.each { |file| require file }

module Features
  # Extend this module in spec/support/features/*.rb
  include Formulaic::Dsl
end

RSpec.configure do |config|
  config.infer_base_class_for_anonymous_controllers = false
  config.infer_spec_type_from_file_location!
  config.use_transactional_fixtures = false

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
    DatabaseCleaner[:active_record, { model: Support::LoadEvent }].clean_with(:truncation)
    DatabaseCleaner[:active_record, { model: Support::SanityCheck }].clean_with(:truncation)
    DatabaseCleaner[:active_record, { model: Support::StudyXmlRecord }].clean_with(:truncation)
    DatabaseCleaner[:active_record, { model: Study }].clean_with(:truncation)
  end

  config.before(:each) do |example|
    # clear database
    db = Util::DbManager.new
    db.remove_indexes_and_constraints
    StudyRelationship.remove_all_data
    # db.add_indexes_and_constraints # TODO: add back in when we have a way to add indexes and constraints

    Util::DbManager.new({:event => Support::LoadEvent.new}).remove_indexes_and_constraints
    unit_test = ![:feature, :request].include?(example.metadata[:type])
    strategy = unit_test ? :transaction : :truncation
    allow_any_instance_of( Util::DbManager ).to receive(:add_indexes_and_constraints).and_return(nil)

    DatabaseCleaner.strategy = strategy
    DatabaseCleaner[:active_record, { model: Support::LoadEvent }].strategy = strategy
    DatabaseCleaner[:active_record, { model: Support::SanityCheck }].strategy = strategy
    DatabaseCleaner[:active_record, { model: Support::StudyXmlRecord }].strategy = strategy
    DatabaseCleaner[:active_record, { model: Study }].clean_with(:truncation)

    DatabaseCleaner.start
    DatabaseCleaner[:active_record, { model: Support::LoadEvent }].start
    DatabaseCleaner[:active_record, { model: Support::SanityCheck }].start
    DatabaseCleaner[:active_record, { model: Support::StudyXmlRecord }].start

    # ensure app user logged into db connections
    PublicBase.establish_connection
    ActiveRecord::Base.establish_connection
  end

  config.after(:each) do
    DatabaseCleaner.clean
    DatabaseCleaner[:active_record, { model: Support::LoadEvent }].clean
    DatabaseCleaner[:active_record, { model: Support::SanityCheck }].clean
    DatabaseCleaner[:active_record, { model: Support::StudyXmlRecord }].clean
    DatabaseCleaner[:active_record, { model: Study }].clean
  end

end
