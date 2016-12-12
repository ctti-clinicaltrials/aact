module ClinicalTrials
  class Client
    BASE_URL = 'https://clinicaltrials.gov'

    attr_reader :url, :processed_studies, :dry_run, :errors
    def initialize(search_term: nil, dry_run: false)
      @url = "#{BASE_URL}/search?term=#{search_term.try(:split).try(:join, '+')}&resultsxml=true"
      @processed_studies = {
        updated_studies: [],
        new_studies: []
      }
      @dry_run = dry_run
      @errors = []
    end

    def download_xml_files
      tries ||= 5

      file = Tempfile.new('xml')

      begin
        download = RestClient::Request.execute({
          url:          @url,
          method:       :get,
          content_type: 'application/zip'
        })
      rescue Errno::ECONNRESET => e
        if (tries -=1) > 0
          retry
        end
      end

      file.binmode
      file.write(download)
      file.size

      Zip::File.open(file.path) do |zipfile|
        zipfile.each do |file|
          study_xml = file.get_input_stream.read
          create_study_xml_record(study_xml)
        end
      end
    end

    def get_xml_for(nct_id)
      url="#{BASE_URL}/show/#{nct_id}?resultsxml=true"
      Nokogiri::XML(Faraday.get(url).body)
    end

    def create_study_xml_record(xml)
      nct_id = extract_nct_id_from_study(xml)

      if @processed_studies[:updated_studies].include?(nct_id)
        @processed_studies[:updated_studies].delete(nct_id)
      end
      @processed_studies[:new_studies] << nct_id
      unless @dry_run
        StudyXmlRecord.where(nct_id: nct_id).first_or_create do |xml_record|
          xml_record.content = xml
        end
      end
    end

    def populate_studies
      return if @dry_run
      load_event = ClinicalTrials::LoadEvent.create(
        event_type: 'populate_studies'
      )

      StudyXmlRecord.find_each do |xml_record|
        raw_xml = xml_record.content

        begin
          import_xml_file(raw_xml)
          xml_record.created_study_at=Date.today
          xml_record.save!
        rescue StandardError => e
          existing_error = @errors.find do |err|
            err[:name] == e.name && err[:first_backtrace_line] == e.backtrace.first
          end

          if existing_error.present?
            existing_error[:count] += 1
          else
            @errors << { name: e.name, first_backtrace_line: e.backtrace.first, count: 0 }
          end

          next
        end
      end

      load_event.complete
    end

    def import_xml_file(study_xml, benchmark: false)
      study = Nokogiri::XML(study_xml)
      nct_id = extract_nct_id_from_study(study_xml)

      unless Study.find_by(nct_id: nct_id).present?
        Study.new({xml: study, nct_id: nct_id}).create
      end
    end

    private

    def extract_nct_id_from_study(study)
      Nokogiri::XML(study).xpath('//nct_id').text
    end

  end
end
