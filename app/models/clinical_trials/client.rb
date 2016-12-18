module ClinicalTrials
  class Client
    BASE_URL = 'https://clinicaltrials.gov'

    attr_reader :url, :processed_studies, :dry_run, :errors
    def initialize(search_term: nil, dry_run: false)
      @url = "#{BASE_URL}/search?term=#{search_term.try(:split).try(:join, '+')}&resultsxml=true"
      #@url = "#{BASE_URL}/search?term=Mesothelioma&resultsxml=true"
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
        puts "downloading xml file from #{@url}..."
        download = RestClient::Request.execute({
          url:          @url,
          method:       :get,
          content_type: 'application/zip'
        })
      rescue Errno::ECONNRESET => e
        if (tries -=1) > 0
          puts "  download failed.  trying again..."
          retry
        end
      end

      file.binmode
      file.write(download)
      file.size

      Zip::File.open(file.path) do |zipfile|
        cnt=zipfile.size
        puts "Populating StudyXmlRecords table with #{cnt} rows..."
        zipfile.each do |file|
          xml = file.get_input_stream.read
          nct_id = extract_nct_id_from_study(xml)
          puts "add study_xml_record: #{cnt} #{nct_id}"
          create_study_xml_record(nct_id,xml)
          cnt=cnt-1
        end
      end
    end

    def get_xml_for(nct_id)
      url="#{BASE_URL}/show/#{nct_id}?resultsxml=true"
      Nokogiri::XML(Faraday.get(url).body)
    end

    def create_study_xml_record(nct_id,xml)
      if @processed_studies[:updated_studies].include?(nct_id)
        @processed_studies[:updated_studies].delete(nct_id)
      end
      @processed_studies[:new_studies] << nct_id
      StudyXmlRecord.where(nct_id: nct_id).first_or_create {|rec|rec.content = xml} unless @dry_run
    end

    def populate_studies(study_filter=nil)
      return if @dry_run
      load_event = ClinicalTrials::LoadEvent.create( event_type: 'populate_studies')

      studies_to_load=StudyXmlRecord.not_yet_loaded(study_filter)
      cntr=studies_to_load.size
      puts "will load #{cntr} studies..."
      studies_to_load.each do |xml_record|
        raw_xml = xml_record.content

        import_xml_file(raw_xml)
        xml_record.created_study_at=Date.today
        xml_record.save!
        puts "#{cntr} saved #{xml_record.nct_id}"
        cntr=cntr-1
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
