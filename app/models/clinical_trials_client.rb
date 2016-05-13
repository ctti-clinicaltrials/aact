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
      nct_id = extract_nct_id_from_study(study)

      study_record = Study.new({ xml: Nokogiri::XML(study), nct_id: nct_id })

      if new_study?(study) || study_changed?(existing_study: study_record, new_study_xml: study)
        study_record.create
      end

    end
  end

  private

  def extract_nct_id_from_study(study)
    Nokogiri::XML(study).xpath('//nct_id').text
  end

  def new_study?(study)
    found = Study.find_by(nct_id: extract_nct_id_from_study(study))

    if found
      false
    else
      true
    end
  end

  def study_changed?(existing_study:, new_study_xml:)
    date_string = Nokogiri::XML(new_study_xml).xpath('//clinical_study').xpath('lastchanged_date').inner_html
    date = Date.parse(date_string)

    date == existing_study.last_changed_date
  end
end

