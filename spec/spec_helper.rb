require "webmock/rspec"

describe 'Export the ctgov schema from aact_test to aact_pub_test' do
  before(:all) do
    db = Util::DbManager.new
    file_path=db.dump_database
    public_connection = PublicBase.connection
    db.restore_database(public_connection, file_path)
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
