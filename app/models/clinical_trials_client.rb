class ClinicalTrialsClient
  BASE_URL = 'https://clinicaltrials.gov'

  attr_reader :url

  def initialize(search_term:)
    @url = "#{BASE_URL}/search?term=#{search_term.split.join('+')}&resultsxml=true"
  end
end
