class ClinicalTrialsApi
  BASE_URL = 'https://clinicaltrials.gov/api/info'

  def self.study_statistics
    body = Faraday.get("#{BASE_URL}/study_statistics?fmt=json").body
    JSON.parse(body)
  end

  def self.number_of_studies
    ClinicalTrialsApi.study_statistics.dig('StudyStatistics','ElmtDefs', 'Study', 'nInstances')
  end
end
