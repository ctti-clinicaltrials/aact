require 'helpers/form_helpers.rb'
ENV["RACK_ENV"] = "test"
ENV["RAILS_ENV"] = "test"

require File.expand_path("../../config/environment", __FILE__)
abort("AACT_ADMIN_DATABASE_URL environment variable is set")   if !ENV["AACT_ADMIN_DATABASE_URL"]
abort("AACT_BACK_DATABASE_URL environment variable is set")    if !ENV["AACT_BACK_DATABASE_URL"]
abort("AACT_STAGE_DATABASE_URL environment variable is set")   if !ENV["AACT_STAGE_DATABASE_URL"]
abort("AACT_PUBLIC_DATABASE_URL environment variable is set")  if !ENV["AACT_PUBLIC_DATABASE_URL"]
abort("AACT_PUBLIC_HOSTNAME environment variable is set")      if !ENV["AACT_PUBLIC_HOSTNAME"]
abort("AACT_PUBLIC_DATABASE_NAME environment variable is set") if !ENV["AACT_PUBLIC_DATABASE_NAME"]
abort("DB_SUPER_USERNAME environment variable is set") if !ENV["DB_SUPER_USERNAME"]

require "rspec/rails"

Dir[Rails.root.join("spec/support/**/*.rb")].sort.each { |file| require file }

module Features
  # Extend this module in spec/support/features/*.rb
  include Formulaic::Dsl
end

RSpec.configure do |config|
  config.include Features, type: :feature
  config.infer_base_class_for_anonymous_controllers = false
  config.infer_spec_type_from_file_location!
  config.use_transactional_fixtures = false

  config.include FormHelpers, :type => :feature
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Devise::Test::ControllerHelpers, type: :view

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
    DatabaseCleaner[:active_record, { model: Admin::LoadEvent }].clean_with(:truncation)
    DatabaseCleaner[:active_record, { model: Admin::UserEvent }].clean_with(:truncation)
    DatabaseCleaner[:active_record, { model: Admin::SanityCheck }].clean_with(:truncation)
    DatabaseCleaner[:active_record, { model: StudyXmlRecord }].clean_with(:truncation)
    DatabaseCleaner[:active_record, { model: Study }].clean_with(:truncation)
  end

  config.before(:each) do |example|
    unit_test = ![:feature, :request].include?(example.metadata[:type])
    strategy = unit_test ? :transaction : :truncation

    DatabaseCleaner.strategy = strategy
    DatabaseCleaner[:active_record, { model: Admin::LoadEvent }].strategy = strategy
    DatabaseCleaner[:active_record, { model: Admin::UserEvent }].strategy = strategy
    DatabaseCleaner[:active_record, { model: Admin::SanityCheck }].strategy = strategy
    DatabaseCleaner[:active_record, { model: StudyXmlRecord }].strategy = strategy

    DatabaseCleaner.start
    DatabaseCleaner[:active_record, { model: Admin::LoadEvent }].start
    DatabaseCleaner[:active_record, { model: Admin::UserEvent }].start
    DatabaseCleaner[:active_record, { model: Admin::SanityCheck }].start
    DatabaseCleaner[:active_record, { model: StudyXmlRecord }].start
  end

  config.after(:each) do
    DatabaseCleaner.clean
    DatabaseCleaner[:active_record, { model: Admin::LoadEvent }].clean
    DatabaseCleaner[:active_record, { model: Admin::UserEvent }].clean
    DatabaseCleaner[:active_record, { model: Admin::SanityCheck }].clean
    DatabaseCleaner[:active_record, { model: StudyXmlRecord }].clean
    DatabaseCleaner[:active_record, { model: Study }].clean
  end

end

ActiveRecord::Migration.maintain_test_schema!
