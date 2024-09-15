# Load necessary libraries for testing
require "rails_helper" # TODO: do I have to require this?
require "webmock/rspec" # what does this do?

# Require the HttpService module
require_relative "../../app/services/http_service" 

describe HttpService do
  let(:retries) { 3 }
  let(:base_url) { "https://example.com/api/" }

  # Dynamically create a class for testing that includes HttpService
  # TODO: rename to client after testing
  let(:service_class) do
    Class.new do
      include HttpService
    end
  end

  let(:service) { service_class.new }

  before do
    service.setup_connection(base_url, retries: retries)
  end

  describe "#setup_connection" do
    let(:connection) { service.instance_variable_get(:@connection) }
    let(:handlers) { connection.builder.handlers }

    it "sets up the connection as a Faraday connection" do
      expect(connection).to be_a(Faraday::Connection)
    end

    it "includes the JSON response middleware" do
      expect(handlers).to include(Faraday::Response::Json)
    end

    it "includes the JSON request middleware" do
      expect(handlers).to include(Faraday::Request::Json)
    end

    it "configures the retry middleware" do
      expect(handlers).to include(Faraday::Retry::Middleware)
    end
  end

  describe "#get" do
    let(:endpoint) { "endpoint" }
    let(:params) { { param1: "value1", param2: "value2" } }
    let(:response_body) { { "key" => "value" } }

    
    context "successful request" do
      # better name that includes parsing json
      it "returns a successful response" do
        # Stub the HTTP request using WebMock
        stub_request(:get, "#{base_url}#{endpoint}")
          .with(query: params)
          .to_return(
            status: 200,
            body: response_body.to_json, # simulate a JSON response
            headers: { "Content-Type": "application/json" }
            )

        response = service.get(endpoint, params)
        expect(response).to eq(response_body)
      end
    end

    context 'handling errors' do
      it 'returns nil when a Faraday::Error occurs' do
        stub_request(:get, "#{base_url}#{endpoint}")
          .with(query: params)
          .to_timeout  # Simulate a timeout

        response = service.get(endpoint, params)
        expect(response).to be_nil
      end

      # TODO: quotes and params are probably optional
      it 'retries the request 3 times before returning nil on timeout' do
        stub_request(:get, "#{base_url}#{endpoint}").with(query: params).to_timeout
        response = service.get(endpoint, params)
        # after 3 retries, it returns nil
        expect(response).to be_nil

        # Assert that the request was retried 3 times
        expect(WebMock).to have_requested(:get, "#{base_url}#{endpoint}")
                          .with(query: params)
                          .at_least(3).times
      end
    end
  end
end

