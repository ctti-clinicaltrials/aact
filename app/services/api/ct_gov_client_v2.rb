# TODO: Would it be better to use DI instead of inheritance here?
module API
  class CTGovClientV2 < HttpService

    BASE_URL = "https://clinicaltrials.gov/api/v2/".freeze

    def initialize
    super(BASE_URL)
    end

    def study(nct_id)
      get("studies/#{nct_id}")
    end

    def studies(fields: nil, page_size: 4, limit: nil)
      items = []
      page_token = nil

      params = { pageSize: page_size }
      params[:fields] = fields
        
      loop do
        params[:pageToken] = page_token
        Rails.logger.debug("Params: #{params}")

        result = get("studies", params.compact)
        studies = result["studies"] if result
        break if studies.nil? or studies.empty?

        items.concat(studies)
        break if items.size >= limit

        page_token = result["nextPageToken"]
        break if page_token.nil?
      end
      items
    end
  end
end