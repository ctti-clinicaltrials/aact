class ClinicalTrialsApiV2
  # based on api: https://clinicaltrials.gov/data-about-studies/learn-about-api
  
  BASE_URL_V2 = 'https://clinicaltrials.gov/api/v2/'


  #Studies/Related to clinical trial studies

  #Studies
  def self.studies
    body = Faraday.get("#{BASE_URL_V2}/studies").body
    JSON.parse(body)
  end

  #Single Study
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
    found = Float::INFINITY
    offset = 1
    items = []
    while items.length < found
      t = Time.now
      url = "#{BASE_URL_V2}studies?fields=NCTId%2CStudyFirstSubmitDate%2CLastUpdatePostDate&pageSize=1000&pageToken=KV1-65uFlPYo"
      # puts url
      attempts = 0
      begin
        next if attempts > 3
        json = JSON.parse(Faraday.get(url).body)
      rescue Faraday::ConnectionFailed
        attempts += 1
        retry
      rescue JSON::ParserError
        attempts += 1
        retry
      end
      byebug
      page = json["studies"].map{|rec| 
                              {"id" => rec["protocolSection"]["identificationModule"]["nctId"],
                              "posted" => rec["protocolSection"]["statusModule"]["studyFirstSubmitDate"], 
                              "updated" => rec["protocolSection"]["statusModule"]["lastUpdatePostDateStruct"]["date"]}}

    #   found = json['studies']['identificationModule']
    #   puts "current: #{items.length} found: #{found}, min: #{offset} max: #{offset + 1000}"
    #   json['StudyFieldsResponse']["StudyFields"].each do |item|
    #     items << { 
    #       id: item["nctId"].first,
    #       posted: Date.parse(item["StudyFirstSubmitDate"].first),
    #       updated: Date.parse(item["LastUpdatePostDate"].first)
    #     }
    #   end
    #   items.uniq!
    #   offset = offset < found ? offset + 1000 : 1
    #   puts "loop #{Time.now - t}"
    # end
    # return items
  end

end
