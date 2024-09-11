module CTGov
  class ApiClient::V2 < ApiClient::Base

    def initialize
      super(version: "v2")
    end

    def version
      "2"
    end

    # TODO: Review option of returning hash ({ nct_id:, content:})
    def nct_id_path
      ["protocolSection", "identificationModule", "nctId"]
    end

    def fetch_studies(range: nil, nct_ids: nil, page_size: nil)
      page_token = nil
      total_count = 0
      total_fetched = 0

      params = { pageSize: page_size, countTotal: true }
      params["query.term"] = range
      params["filter.ids"] = nct_ids

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
      fetch_studies(range: query_term, page_size: page_size) do |studies|
        yield studies
      end
    end

    def get_studies_by_nct_ids(list:, page_size: 50)
      nct_ids = list.join('|')
      fetch_studies(nct_ids: nct_ids, page_size: page_size) do |studies|
        yield studies
      end
    end

    private

    def build_date_range_query(start_date:, end_date: nil)
      "AREA[LastUpdatePostDate]RANGE[#{start_date},#{end_date || 'MAX'}]"
    end
  end
end