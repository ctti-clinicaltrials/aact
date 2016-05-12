class ClinicalTrialsClient
  BASE_URL = 'https://clinicaltrials.gov'

  attr_reader :url

  def initialize(search_term: nil)
    @url = "#{BASE_URL}/search?term=#{search_term.try(:split).try(:join, '+')}&resultsxml=true"
  end

  def get_studies
    
  end

  def populate_studies(studies)
    studies.each do |study|
      nct_id = extract_nct_id(study: study)

      Study.new({ xml: study, nct_id: nct_id }).save
    end
  end

  private

  def extract_nct_id(study:)
    Nokogiri::XML(study).xpath('//nct_id').text
  end
end
