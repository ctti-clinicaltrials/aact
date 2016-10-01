module ClinicalTrials
  class Client
    BASE_URL = 'https://clinicaltrials.gov'
    attr_reader :url, :processed_studies, :dry_run, :updater

    def initialize(params={})
      @dry_run=params[:dry_run]
      @dry_run=false if @dry_run.nil?
      @updater=params[:updater]
      search_term=@updater.params[:search_term]
      @url = "#{BASE_URL}/search?term=#{search_term.try(:split).try(:join, '+')}&resultsxml=true"
      @processed_studies = {
        updated_studies: [],
        new_studies: []
      }
      @dry_run = dry_run
      @errors = []
      self
    end

    def download_xml_file
      tries ||= 5
      file = Tempfile.new('xml')

      begin
        log('client: downloading xml file')
        download = RestClient::Request.execute({
          url:          @url,
          method:       :get,
          content_type: 'application/zip'
        })
      rescue Errno::ECONNRESET => e
        if (tries -=1) > 0
          log("client: error connecting to #{@url}. Retry...")
          retry
        end
      end

      file.binmode
      file.write(download)
      file.size
      file
      file_name="ctgov_#{Time.now.strftime("%Y%m%d%H")}.xml"
      ClinicalTrials::FileManager.new.upload_to_s3({:directory_name=>'xml_downloads',:file_name=>file_name,:file=>file})
    end

    def populate_xml_table(file_name)
      zipfile=ClinicalTrials::FileManager.get_file({:directory_name=>'xml_downloads',:file_name=>file_name})
      zipfile.each do |file|
        study_xml = file.get_input_stream.read
        create_study_xml_record(study_xml)
      end
    end

    def get_xml_for(nct_id)
      begin
        url="#{BASE_URL}/show/#{nct_id}?resultsxml=true"
        Nokogiri::XML(call_to_ctgov(url))
      rescue => error
        raise error
      end
    end

    def call_to_ctgov(query_url)
      begin
        tries=20
        Faraday.get(query_url).body
      rescue => error
        tries = tries-1
        if tries > 0
          sleep(5)
          retry
        else
          raise error
        end
      end
    end

    def create_study_xml_record(xml)
      nct_id = extract_nct_id_from_study(xml)

      if @processed_studies[:updated_studies].include?(nct_id)
        @processed_studies[:updated_studies].delete(nct_id)
      end
      @processed_studies[:new_studies] << nct_id
      unless @dry_run
        StudyXmlRecord.where(nct_id: nct_id).first_or_create do |xml_record|
          @updater.decrement_count_down
          show_progress(nct_id,'creating study')
          xml_record.content = xml
        end
      end
    end

    def create_studies
      return if @dry_run
      study_counter=0
      unloaded_xml_records=StudyXmlRecord.not_yet_loaded
      log("client: populating study tables with #{unloaded_xml_records.size} xml records...")
      @updater.study_counts[:should_add]=unloaded_xml_records.size
      @updater.study_counts[:count_down]=unloaded_xml_records.size
      unloaded_xml_records.each{|xml_record|
        raw_xml = xml_record.content
        @updater.decrement_count_down
        begin
          import_xml_file(raw_xml)
          xml_record.was_created
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
      }
    end

    def import_xml_file(study_xml, benchmark: false)
      study = Nokogiri::XML(study_xml)
      nct_id = extract_nct_id_from_study(study_xml)
      show_progress(nct_id,'stashing xml')
      if Study.find_by(nct_id: nct_id).present?
        log "Study #{nct_id} already exists"
      else
        puts "Creating study #{nct_id}"
        Study.new({
          xml: study,
          nct_id: nct_id
        }).create
      end
    end

    private

    def log(msg)
      @updater.log(msg)
    end

    def show_progress(nct_id,action)
      @updater.show_progress(nct_id,action)
    end

    def extract_nct_id_from_study(study)
      Nokogiri::XML(study).xpath('//nct_id').text
    end

  end
end
