module ClinicalTrials
  class Client
    BASE_URL = 'https://clinicaltrials.gov'

    attr_reader :url, :processed_studies, :dry_run
    def initialize(search_term: nil, dry_run: false)
      @url = "#{BASE_URL}/search?term=#{search_term.try(:split).try(:join, '+')}&resultsxml=true"
      @processed_studies = {
        updated_studies: [],
        new_studies: []
      }
      @dry_run = dry_run
    end

    def download_xml_files
      load_event = ClinicalTrials::LoadEvent.create(
        event_type: 'get_studies'
      ) unless @dry_run

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
          create_study_xml_record(study_xml)
        end
      end

      load_event.complete unless @dry_run
    end

    def create_study_xml_record(xml)
      nct_id = extract_nct_id_from_study(xml)
      new_study_xml = Nokogiri::XML(xml)
      existing_study_xml_record = StudyXmlRecord.find_by(nct_id: nct_id)
      existing_study_xml = Nokogiri::XML(existing_study_xml_record.try(:content))

      if existing_study_xml_record.blank?
        if @processed_studies[:updated_studies].include?(nct_id)
          @processed_studies[:updated_studies].delete(nct_id)
        end
        @processed_studies[:new_studies] << nct_id
        StudyXmlRecord.create(content: xml, nct_id: nct_id) unless @dry_run
        # report number of new records
      elsif study_xml_changed?(existing_study_xml: existing_study_xml, new_study_xml: new_study_xml)
        if @processed_studies[:new_studies].include?(nct_id)
          @processed_studies[:new_studies].delete(nct_id)
        end
        @processed_studies[:updated_studies] << nct_id
        existing_study_xml_record.update(content: xml) unless @dry_run
        # report number of changed records
      end
    end

    def populate_studies
      return if @dry_run
      load_event = ClinicalTrials::LoadEvent.create(
        event_type: 'populate_studies'
      )

      nct_ids = (@processed_studies[:new_studies] + @processed_studies[:updated_studies]).uniq

      if nct_ids.present?
        nct_ids.lazy.each do |nct_id|
          xml_record = StudyXmlRecord.find_by(nct_id: nct_id)
          raw_xml = xml_record.content
          import_xml_file(raw_xml)
        end
      else
        StudyXmlRecord.find_each do |xml_record|
          raw_xml = xml_record.content
          import_xml_file(raw_xml)
        end
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

      study_record = Study.new({
        xml: study,
        nct_id: nct_id
      })

      study_record.create
      # report number of new records

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

    def study_xml_changed?(existing_study_xml:, new_study_xml:)
      existing_study_xml.diff(new_study_xml) do |change,node|
        return true if !change.blank? && node.parent.name != 'download_date'
      end
      false
    end

    def study_changed?(existing_study:, new_study_xml:)
      date_string = new_study_xml.xpath('//clinical_study')
      .xpath('lastchanged_date').text

      date = Date.parse(date_string)

      date != existing_study.last_changed_date
    end
  end
end
