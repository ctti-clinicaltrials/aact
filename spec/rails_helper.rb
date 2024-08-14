ENV["RACK_ENV"] = "test"
ENV["RAILS_ENV"] = "test"

require File.expand_path("../../config/environment", __FILE__)
require "rspec/rails"

# TODO: move json samples from support - slows down the tests
Dir[Rails.root.join("spec/support/**/*.rb")].sort.each { |file| require file }

module Features
  # Extend this module in spec/support/features/*.rb
  include Formulaic::Dsl
end

RSpec.configure do |config|
  config.infer_base_class_for_anonymous_controllers = false
  config.infer_spec_type_from_file_location!
  config.use_transactional_fixtures = false

  config.include SchemaSwitcher # TODO: do we still need it?
  config.include ModelDataHelper, type: :model


  config.before(:each) do |example|
    # TODO: do we have remove constraints before each test? Add after?
    db = Util::DbManager.new
    db.remove_indexes_and_constraints
    StudyRelationship.remove_all_data # should we clean up after the test?
    
    # db.add_indexes_and_constraints # TODO: add back in when we have a way to add indexes and constraints

    # tests that are not feature or request tests are considered unit tests
    unit_test = ![:feature, :request].include?(example.metadata[:type])
    strategy = unit_test ? :transaction : :truncation

    # how does this line work? 
    allow_any_instance_of( Util::DbManager ).to receive(:add_indexes_and_constraints).and_return(nil)
  end
end
