class ClinicalTrialsApiV2
  # based on api: https://clinicaltrials.gov/data-about-studies/learn-about-api
  
  BASE_URL_V2 = 'https://clinicaltrials.gov/api/v2'

  # TODO: double check potential // issue in the url

  #Studies/Related to clinical trial studies

  #Studies
  def self.studies
    body = Faraday.get("#{BASE_URL_V2}/studies").body
    JSON.parse(body)
  end

  #Single Study
  # GET https://clinicaltrials.gov/api/v2/studies/NCT04678856
  def self.study(nctId)
    body = Faraday.get("#{BASE_URL_V2}/studies/#{nctId}").body
    JSON.parse(body)
  end 

  #Data Model Fields
  def self.metadata
    body = Faraday.get("#{BASE_URL_V2}/studies/metadata").body
    JSON.parse(body)
  end


  #Stats/Data statistics

  #Study Size
  def self.size
    body = Faraday.get("#{BASE_URL_V2}/stats/size").body
    JSON.parse(body)
  end

  #Values stats
  def self.values
    body = Faraday.get("#{BASE_URL_V2}/stats/fieldValues").body
    JSON.parse(body)
  end

  #Field Values Stats
  def field_values(field)
    body = Faraday.get("#{BASE_URL_V2}/stats/fieldValues/#{field}").body
    JSON.parse(body)
  end

  #List Sizes
  def list_sizes
    body = Faraday.get("#{BASE_URL_V2}/stats/listSizes").body
    JSON.parse(body)
  end

  #List Field Size
  def list_fields(field)
    body = Faraday.get("#{BASE_URL_V2}/stats/listSizes/#{field}").body
    JSON.parse(body)
  end

  # get all the studies from ctgov
  def self.all(days_back: nil)
    puts "getting all studies from v2 api..."
    offset = 1
    items = []

    page_token = nil

    loop do
      url = "#{BASE_URL_V2}/studies?fields=NCTId%2CStudyFirstSubmitDate%2CLastUpdatePostDate&pageSize=1000"
      url += "&pageToken=#{page_token}" if page_token

      attempts = 0
      begin
        json_response = JSON.parse(Faraday.get(url).body)
      rescue Faraday::ConnectionFailed
        attempts += 1
        retry if attempts <= 3
      rescue JSON::ParserError
        attempts += 1
        retry if attempts <= 3
      end

      studies = json_response["studies"]
      break if studies.empty?

      studies.each do |rec|
        items << {
          # TODO: review the key names - not the same as for v1
          nct_id: rec["protocolSection"]["identificationModule"]["nctId"],
          # posted: rec["protocolSection"]["statusModule"]["studyFirstSubmitDate"],
          updated: rec["protocolSection"]["statusModule"]["lastUpdatePostDateStruct"]["date"]
        }
      end

      puts "items: #{items.length}"

      page_token = json_response["nextPageToken"]
      break if page_token.nil?
    end
    return items
  end

end
