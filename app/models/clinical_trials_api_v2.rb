class ClinicalTrialsApiV2
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
  def fieldValues(field)
    body = Faraday.get("#{BASE_URL_V2}/stats/fieldValues/#{field}").body
    JSON.parse(body)
  end

  #List Sizes
  def listSizes
    body = Faraday.get("#{BASE_URL_V2}/stats/listSizes").body
    JSON.parse(body)
  end

  #List Field Size
  def listFields(field)
    body = Faraday.get("#{BASE_URL_V2}/stats/listSizes/#{field}").body
    JSON.parse(body)
  end

end
