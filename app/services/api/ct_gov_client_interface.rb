module API
  module CTGovClientInterface
    BASE_URL = "https://clinicaltrials.gov/api/".freeze

    # fetch a single study by nct_id - is not a dependency for the sync process

    def fetch_studies(query_term:, page_size:)
      raise NotImplementedError, "You must implement fetch_studies"
    end

    def get_studies_in_date_range(start_date:, end_date: nil, page_size:)
      raise NotImplementedError, "You must implement get_studies_in_date_range"
    end
  end
end