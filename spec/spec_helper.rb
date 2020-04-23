require "webmock/rspec"

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

  # config.before(:each) do
  #   stub_request(:get, /api.github.com/).
  #     with(headers: {'Accept'=>'*/*', 'User-Agent'=>'Ruby'}).
  #     to_return(status: 200, body: "stubbed response", headers: {})
  # end
end

WebMock.disable_net_connect!(allow_localhost: true)
