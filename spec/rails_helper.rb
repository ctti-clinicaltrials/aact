ENV["RACK_ENV"] = "test"

require File.expand_path("../../config/environment", __FILE__)
abort("AACT_ADMIN_DATABASE_URL environment variable is set")  if !ENV["AACT_ADMIN_DATABASE_URL"]
abort("AACT_BACK_DATABASE_URL environment variable is set")   if !ENV["AACT_BACK_DATABASE_URL"]
abort("AACT_PUBLIC_DATABASE_URL environment variable is set") if !ENV["AACT_PUBLIC_DATABASE_URL"]

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

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
    DatabaseCleaner[:active_record, { model: LoadEvent }].clean_with(:truncation)
    DatabaseCleaner[:active_record, { model: SanityCheck }].clean_with(:truncation)
    DatabaseCleaner[:active_record, { model: StudyXmlRecord }].clean_with(:truncation)
  end

    config.before(:each) do |example|
    unit_test = ![:feature, :request].include?(example.metadata[:type])
    strategy = unit_test ? :transaction : :truncation

    DatabaseCleaner.strategy = strategy
    DatabaseCleaner[:active_record, { model: LoadEvent }].strategy = strategy
    DatabaseCleaner[:active_record, { model: SanityCheck }].strategy = strategy
    DatabaseCleaner[:active_record, { model: StudyXmlRecord }].strategy = strategy

    DatabaseCleaner.start
    DatabaseCleaner[:active_record, { model: LoadEvent }].start
    DatabaseCleaner[:active_record, { model: SanityCheck }].start
    DatabaseCleaner[:active_record, { model: StudyXmlRecord }].start
  end

  config.after(:each) do
    DatabaseCleaner.clean
    DatabaseCleaner[:active_record, { model: LoadEvent }].clean
    DatabaseCleaner[:active_record, { model: SanityCheck }].clean
    DatabaseCleaner[:active_record, { model: StudyXmlRecord }].clean
  end

end

ActiveRecord::Migration.maintain_test_schema!
