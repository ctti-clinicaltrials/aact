module CTGov
  class ApiClient::Base
    include HttpClient

    BASE_URL = "https://clinicaltrials.gov/api".freeze

    def initialize(version:)
      setup_connection("#{BASE_URL}/#{version}/")
    end

    # StudySyncService calls this methods on the client
    def version
      raise NotImplementedError, "You must implement version method"
    end

    def nct_id_path
      raise NotImplementedError, "You must implement nct_id_path method"
    end

    def get_studies_in_date_range(start_date:, end_date: nil, page_size:)
      raise NotImplementedError, "You must implement get_studies_in_date_range"
    end

    def get_studies_by_nct_ids(list:, page_size:)
      raise NotImplementedError, "You must implement get_studies_by_nct_ids"
    end
  end
end