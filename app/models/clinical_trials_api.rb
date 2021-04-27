class ClinicalTrialsApi
  BASE_URL = 'https://clinicaltrials.gov/api/info'

  def self.study_statistics
    body = Faraday.get("#{BASE_URL}/study_statistics?fmt=json").body
    JSON.parse(body)
  end

  def self.number_of_studies
    ClinicalTrialsApi.study_statistics.dig('StudyStatistics','ElmtDefs', 'Study', 'nInstances')
  end

  def self.studies(query='')
    found = Float::INFINITY
    offset = 1
    items = []
    while items.length < found
      url = "https://clinicaltrials.gov/api/query/study_fields?expr=AREA%5BConditionSearch%5D%22covid-19%22&fields=NCTId%2CStudyFirstPostDate%2CLastUpdatePostDate&min_rnk=#{min}&max_rnk=#{max}&fmt=json"

      puts url
      json = JSON.parse(Faraday.get(url).body)
      found = json['StudyFieldsResponse']['NStudiesFound']
      puts "FOUND: #{found}"
      json['StudyFieldsResponse']["StudyFields"].each do |item|
        items << { 
          id: item["NCTId"].first,
          posted: Date.parse(item["StudyFirstPostDate"].first),
          updated: Date.parse(item["LastUpdatePostDate"].first)
        }
      end
      items.uniq!
      min += 1000
      max += 1000
      if min > found
        min = 1
        max = 1000
      end
    end
    return items
  end

  # get all the studies from ctgov
  def self.all(days_back: nil)
    found = Float::INFINITY
    offset = 1
    items = []
    while items.length < found
      t = Time.now
      url = "https://clinicaltrials.gov/api/query/study_fields?fields=NCTId%2CStudyFirstPostDate%2CLastUpdatePostDate&min_rnk=#{offset}&max_rnk=#{offset + 999}&fmt=json"
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
      found = json['StudyFieldsResponse']['NStudiesFound']
      puts "current: #{items.length} found: #{found}, min: #{offset} max: #{offset + 1000}"
      json['StudyFieldsResponse']["StudyFields"].each do |item|
        items << { 
          id: item["NCTId"].first,
          posted: Date.parse(item["StudyFirstPostDate"].first),
          updated: Date.parse(item["LastUpdatePostDate"].first)
        }
      end
      items.uniq!
      offset = offset < found ? offset + 1000 : 1
      puts "loop #{Time.now - t}"
    end
    return items
  end
end
