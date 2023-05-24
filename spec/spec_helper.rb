require "webmock/rspec"

describe 'Export the ctgov schema from aact_test to aact_pub_test' do
  before(:all) do
    # db = Util::DbManager.new
    dm=Util::DbManager.new(:load_event=>Support::LoadEvent.create({:event_type=>'incremental',:status=>'running',:description=>'',:problems=>''}))
    fm=Util::FileManager.new
    dm.dump_database
    fm.save_static_copy
    dm.refresh_public_db 
  end
end

# http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.syntax = :expect
  end

  config.mock_with :rspec do |mocks|
    mocks.syntax = :expect
    mocks.verify_partial_doubles = true
  end

  config.example_status_persistence_file_path = "tmp/rspec_examples.txt"
  config.order = :random
end

WebMock.disable_net_connect!(allow_localhost: true)
