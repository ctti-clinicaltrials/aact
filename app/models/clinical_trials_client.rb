require 'zip'
require 'tempfile'

class ClinicalTrialsClient
  BASE_URL = 'https://clinicaltrials.gov'

  attr_reader :url

  def initialize(search_term: nil)
    @url = "#{BASE_URL}/search?term=#{search_term.try(:split).try(:join, '+')}&resultsxml=true"
    @files = []
  end

  def get_studies
    file = Tempfile.new('xml')

    download = RestClient::Request.execute({
      url:          @url,
      method:       :get,
      content_type: 'application/zip'
    })

    file.binmode
    file.write(download)

    Zip::File.open(file.path) do |zipfile|
      zipfile.each do |file|
        @files << file
      end
    end

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
