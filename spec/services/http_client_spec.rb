require "rails_helper"
require_relative "../../app/services/http_client"

describe HttpClient do
  let(:base_url) { "https://example.com/" }
  let(:endpoint) { "api/endpoint" }
  let(:url) { "#{base_url}#{endpoint}" }
  let(:params) { { param1: "value1", param2: "value2" } }
  let(:response_body) { { "key" => "value" } }
  let(:retries) { 2 }

  # Define the webmock stub for GET requests
  let(:get_stub_request) { stub_request(:get, url).with(query: params) }

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

  # including faraday configuration tests since business logic relies on it
  # raising 4xx and 5xx errors, parsing JSON responses, and retrying requests
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
    context "successful request" do
      it "parses and returns JSON response" do
        get_stub_request.to_return(
          status: 200,
          body: response_body.to_json, # simulate a JSON response
          headers: { "Content-Type": "application/json" } # ensure JSON parsing
        )

        response = api_client.get(endpoint, params)
        expect(response).to eq(response_body)
      end
    end

    context "handling errors" do
      it "raises a Faraday::ClientError after no retries for 4xx errors" do
        get_stub_request.to_return(status: 404, body: 'Not Found')

        expect {
          api_client.get(endpoint, params)
        }.to raise_error(Faraday::ClientError)

        # no retries for client errors
        expect(WebMock).to have_requested(:get, url)
                          .with(query: params)
                          .times(1) # initial request only
      end

      it "raises a Faraday::ServerError after retries for 5xx errors" do
        get_stub_request.to_return(status: 500, body: 'Internal Server Error')

        expect {
          api_client.get(endpoint, params)
        }.to raise_error(Faraday::ServerError)

        expect(WebMock).to have_requested(:get, url)
                          .with(query: params)
                          .times(1 + retries) # initial request + retries
      end
    end

    context "when a request times out" do
      it "retries the request and raises Faraday::TimeoutError after retries" do
        get_stub_request.to_timeout

        expect {
          api_client.get(endpoint, params)
        }.to raise_error(Faraday::ConnectionFailed) # final error after retries

        expect(WebMock).to have_requested(:get, url)
                          .with(query: params)
                          .times(1 + retries) # initial request + retries
      end
    end
  end
end