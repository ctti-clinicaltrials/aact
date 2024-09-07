module API
  class CTGovClientV2 < HttpService
    BASE_URL = "https://clinicaltrials.gov/api/v2/".freeze

    def initialize
      super(BASE_URL)
    end

    def fetch_study(nct_id)
      get("studies/#{nct_id}")
    end

    def fetch_studies_paginated(query_term: nil, page_size: nil)
      page_token = nil
      total_count = 0
      total_fetched = 0

      params = { pageSize: page_size, countTotal: true }
      # params[:fields] = fields
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

    def studies(page_token: nil, query_term: nil, page_size: nil, limit: nil)
      params = { pageSize: page_size }
      params[:pageToken] = page_token if page_token
      params["query.term"] = query_term if query_term
      # params["query.term"] = "AREA[LastUpdatePostDate]RANGE[2024-08-30,MAX]"
      params[:countTotal] = true if !page_token # total shown in 1 page response only
      Rails.logger.debug("Params: #{params}")
      get("studies", params.compact)
    end

    def fetch_studies(fields: nil, nct_ids: nil, query_term: nil, page_size: nil, limit: nil)
      items = []
      page_token = nil

      # TODO: optimize this later
      params = { pageSize: page_size, countTotal: true } # total shown in 1 page response only
      params[:fields] = fields
      params["filter.ids"] = nct_ids.join(",") if nct_ids
      params["query.term"] = query_term
        
      loop do
        params[:pageToken] = page_token
        Rails.logger.debug("Params: #{params}")

        result = get("studies", params.compact)
        if result.nil?
          # TODO: handle this better
          Rails.logger.warn("Received nil response from API")
          break
        end
        Rails.logger.info("Total Count: #{result["totalCount"]}") if result["totalCount"]

        studies = result["studies"] if result
        break if studies.nil? or studies.empty?

        items.concat(studies)
        break if items.size >= limit if limit

        page_token = result["nextPageToken"]
        break if page_token.nil?
      end
      items
    end

    def query_term_for(start_date:, end_date: nil)
      "AREA[LastUpdatePostDate]RANGE[#{start_date},#{end_date || 'MAX'}]"
    end

    # start_date is required keyword argument
    def fetch_studies_by_date(start_date:, end_date: nil, page_size: 5, limit: 10)
      Rails.logger.info("Fetching studies for range: #{start_date} - #{end_date || Date.today}")
      query_term = "AREA[LastUpdatePostDate]RANGE[#{start_date},#{end_date || 'MAX'}]"
      fetch_studies(query_term: query_term, page_size: page_size, limit: limit)
      # studies(query_term: query_term, page_size: page_size, limit: limit)
    end
  end
end