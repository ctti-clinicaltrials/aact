module HttpClient
  
  def setup_connection(base_url, timeout: 10, open_timeout: 5, retries: 3)
    retry_options = {
      max: retries,
      interval: 0.05,
      interval_randomness: 0.5,
      backoff_factor: 2,
      methods: %i[get],
      # exceptions to trigger a retry
      exceptions: [
        Faraday::TimeoutError, 
        Faraday::ConnectionFailed,
        Faraday::ServerError
      ]
    }

    @connection = Faraday.new(url: base_url) do |f|
      f.request :json # for post requests - not currently used
      f.request :retry, retry_options # faraday-retry gem
      # using Rails.logger for now - review options
      f.response :logger, Rails.logger, { headers: false, bodies: false, errors: true }
      f.response :raise_error # 40x, 50x errors -> Faraday::ClientError, Faraday::ServerError
      # convert JSON string to Ruby hash inside body if header is application/json
      f.response :json # fails with Faraday::ParsingError
      f.adapter Faraday.default_adapter # keep for clarity
      f.options.timeout = timeout # max timeout for request
      f.options.open_timeout = open_timeout # for connection to open
    end
  end

  def get(endpoint, params = {})
    @connection.get(endpoint, params).body
  end
end