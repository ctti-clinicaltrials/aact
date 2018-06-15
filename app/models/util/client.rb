module Util
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

      file_name="#{Util::FileManager.new.xml_file_directory}/#{Time.zone.now.strftime("%Y%m%d-%H")}.xml"
      file = File.new file_name, 'w'

      begin
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
      file
    end

    def save_file_contents(file)
      Zip::File.open(file.path) do |zipfile|
        cnt=zipfile.size
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
      tries ||= 5
      begin
        url="#{BASE_URL}/show/#{nct_id}?resultsxml=true"
        Nokogiri::XML(Faraday.get(url).body)
      rescue => e
        #  have been encountering timeout errors.  If encountered, try again
        if (tries -=1) > 0
          puts "Error calling: #{url}"
          puts e.inspect
          retry
        end
        puts "Giving up on #{nct_id}.  Move on to next study"
      end
    end

    def create_study_xml_record(nct_id,xml)
      if @processed_studies[:updated_studies].include?(nct_id)
        @processed_studies[:updated_studies].delete(nct_id)
      end
      @processed_studies[:new_studies] << nct_id
      StudyXmlRecord.where(nct_id: nct_id).first_or_create {|rec|rec.content = xml} unless @dry_run
    end

    def populate_studies
      return if @dry_run
      cntr=StudyXmlRecord.not_yet_loaded.count
      start_time=Time.zone.now
      puts "Load #{cntr} studies Start Time.....#{start_time}"

      while cntr > 0
        StudyXmlRecord.find_each do |xml_record|
          stime=Time.zone.now
          if xml_record.created_study_at.blank?
            import_xml_file(xml_record.content)
            xml_record.created_study_at=Date.today
            xml_record.save!
            puts "#{cntr} saved #{xml_record.nct_id}:  #{Time.zone.now - stime}"
          end
          cntr=cntr-1
        end
      end
      puts "Total Load Time:.....#{Time.zone.now - start_time}"
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
