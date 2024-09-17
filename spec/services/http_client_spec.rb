require "rails_helper"
require_relative "../../app/services/http_client"

describe HttpClient do
  let(:base_url) { "https://example.com/api/" }
  let(:retries) { 2 }

  # dynamically create a class for testing
  let(:api_client_class) do
    Class.new do
      include HttpClient
    end
  end

  let(:api_client) { api_client_class.new }

  before do
    api_client.setup_connection(base_url, retries: retries)
  end

  describe "#setup_connection" do
    let(:connection) { api_client.instance_variable_get(:@connection) }
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

    it "includes the raise_error middleware" do
      expect(handlers).to include(Faraday::Response::RaiseError)
    end
  end

  describe "#get" do
    let(:endpoint) { "endpoint" }
    let(:params) { { param1: "value1", param2: "value2" } }
    let(:response_body) { { "key" => "value" } }

    context "successful request" do
      it "parses and returns JSON response" do
        # Stub the HTTP request using WebMock
        stub_request(:get, "#{base_url}#{endpoint}")
          .with(query: params)
          .to_return(
            status: 200,
            body: response_body.to_json, # simulate a JSON response
            headers: { "Content-Type": "application/json" }
            )

        response = api_client.get(endpoint, params)
        expect(response).to eq(response_body)
      end
    end

    context "handling errors" do
      it "when a 4xx error occur, raises a Faraday::ClientError" do
        stub_request(:get, "#{base_url}#{endpoint}")
          .with(query: params)
          .to_return(status: 404, body: 'Not Found')

        expect {
          api_client.get(endpoint, params)
        }.to raise_error(Faraday::ClientError)
      end

      it "when a 5xx error occurs, raises a Faraday::ServerError after retries" do
        stub_request(:get, "#{base_url}#{endpoint}")
          .with(query: params)
          .to_return(status: 500, body: 'Internal Server Error')

        expect {
          api_client.get(endpoint, params)
        }.to raise_error(Faraday::ServerError)

        expect(WebMock).to have_requested(:get, "#{base_url}#{endpoint}")
                          .with(query: params)
                          .times(1 + retries) # initial request + retries
      end
    end

    context "when a request times out" do
      it "retries the request and raises Faraday::TimeoutError after retries" do
        stub_request(:get, "#{base_url}#{endpoint}")
          .with(query: params)
          .to_timeout

        expect {
          api_client.get(endpoint, params)
        }.to raise_error(Faraday::ConnectionFailed) # final error after retries

        expect(WebMock).to have_requested(:get, "#{base_url}#{endpoint}")
                          .with(query: params)
                          .times(1 + retries) # initial request + retries
      end
    end
  end
end