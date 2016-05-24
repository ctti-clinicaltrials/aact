require 'zip'
require 'tempfile'

module ClinicalTrials
  class Client
    BASE_URL = 'https://clinicaltrials.gov'

    attr_reader :url, :files

    def initialize(search_term: nil)
      @url = "#{BASE_URL}/search?term=#{search_term.try(:split).try(:join, '+')}&resultsxml=true"
      @files = []
    end

    def create_studies
      get_studies
      populate_studies(@files)
    end

    def get_studies
      load_event = ClinicalTrials::LoadEvent.create(
        event_type: 'get_studies'
      )

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
          @files << file.get_input_stream.read
        end
      end

      load_event.complete
    end

    def populate_studies(studies)
      load_event = ClinicalTrials::LoadEvent.create(
        event_type: 'populate_studies'
      )
      new = 0
      changed = 0

      study_records = studies.map do |study|
        nct_id = extract_nct_id_from_study(study)

        study_record = Study.new({
          xml: Nokogiri::XML(study),
          nct_id: nct_id
        })

        if new_study?(study)
          new += 1
          study_record
        elsif study_changed?(existing_study: study_record,
                             new_study_xml: study)
          changed += 1
        end

      end

      Study.bulk_insert do |worker|
        study_records.compact.each do |record|
          worker.add(record.attribs.merge(nct_id: record.nct_id))
        end
      end

      load_event.complete
      load_event.generate_report(new: new, changed: changed)
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
      date_string = Nokogiri::XML(new_study_xml)
                              .xpath('//clinical_study')
                              .xpath('lastchanged_date').inner_html

      date = Date.parse(date_string)

      date == existing_study.last_changed_date
    end
  end
end
