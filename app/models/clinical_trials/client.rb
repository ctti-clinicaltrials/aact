require 'zip'
require 'tempfile'
require 'open3'

module ClinicalTrials
  class Client
    BASE_URL = 'https://clinicaltrials.gov'

    attr_reader :url

    def initialize(search_term: nil)
      @url = "#{BASE_URL}/search?term=#{search_term.try(:split).try(:join, '+')}&resultsxml=true"
    end

    def download_xml_files
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
      file.size

      Zip::File.open(file.path) do |zipfile|
        zipfile.each do |file|
          study_xml = file.get_input_stream.read
          nct_id = extract_nct_id_from_study(study_xml)
          existing_study_xml = StudyXmlRecord.find_by(nct_id: nct_id)

          if existing_study_xml.blank?
            StudyXmlRecord.create(content: study_xml, nct_id: nct_id)
            # report number of new records
          # elsif study_changed?(existing_study: existing_study, new_study_xml: study)
          #   return if study.blank?
          #   existing_study.xml = study
          #   existing_study.update(existing_study.attribs)
          #   existing_study.study_xml_record.update(content: study)
            # report number of changed records
          end

        end

      end

      load_event.complete
    end

    def populate_studies
      load_event = ClinicalTrials::LoadEvent.create(
        event_type: 'populate_studies'
      )

      StudyXmlRecord.find_each do |xml_record|
        raw_xml = xml_record.content
        import_xml_file(raw_xml)
      end

      load_event.complete
    end

    def import_xml_file(study_xml, benchmark: false)
      if benchmark
        load_event = ClinicalTrials::LoadEvent.create(
          event_type: 'get_studies'
        )
      end

      study = Nokogiri::XML(study_xml)
      nct_id = extract_nct_id_from_study(study_xml)

      existing_study = Study.find_by(nct_id: nct_id)

      if new_study?(study_xml)
        study_record = Study.new({
          xml: study,
          nct_id: nct_id
        })

        study_record.create
        # report number of new records
      elsif study_changed?(existing_study: existing_study, new_study_xml: study)
        return if study.blank?
        existing_study.xml = study
        existing_study.update(existing_study.attribs)
        existing_study.study_xml_record.update(content: study)
        # report number of changed records
      end

      if benchmark
        load_event.complete
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
      date_string = new_study_xml.xpath('//clinical_study')
      .xpath('lastchanged_date').inner_html

      date = Date.parse(date_string)

      date != existing_study.last_changed_date
    end
  end
end
