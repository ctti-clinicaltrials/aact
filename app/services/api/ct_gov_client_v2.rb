module API
  class CTGovClientV2 < HttpService
    include API::CTGovClientInterface

    def initialize
      super("#{BASE_URL}v2/")
    end

    def fetch_study(nct_id)
      get("studies/#{nct_id}")
    end

    # TODO: error handling
    def fetch_studies(query_term: nil, page_size: nil)
      page_token = nil
      total_count = 0
      total_fetched = 0

      params = { pageSize: page_size, countTotal: true }
      params["query.term"] = query_term

      loop do
        params[:pageToken] = page_token
        Rails.logger.debug("Fetching studies with params: #{params}")

        result = get("studies", params.compact)

        if result.nil? || result["studies"].nil?
          Rails.logger.warn("Received nil response or empty studies from API")
          break
        end

        studies = result["studies"]

        # Capture total count on the first run
        total_count = result["totalCount"] if result["totalCount"]
        total_fetched += studies.size
        Rails.logger.info("Dowloaded #{total_fetched} from #{total_count} studies")

        # Yield each page of studies to the caller
        yield studies

        page_token = result["nextPageToken"]
        break if page_token.nil? || total_fetched >= total_count
      end
    end


    # start_date is required keyword argument
    def get_studies_in_date_range(start_date:, end_date: nil, page_size: nil)
      Rails.logger.info("Fetching studies for range: #{start_date} - #{end_date || Date.today}")
      query_term = build_date_range_query(start_date: start_date, end_date: end_date)
      fetch_studies(query_term: query_term, page_size: page_size) do |studies|
        yield studies
      end
    end

    private

    def build_date_range_query(start_date:, end_date: nil)
      "AREA[LastUpdatePostDate]RANGE[#{start_date},#{end_date || 'MAX'}]"
    end

  end
end