class StudyDownloader
    def self.download_recently_updated
      # ActiveRecord::Base.logger.silence do # silence method error
      find_studies_to_update.each do |nct_id|
        record = StudyJsonRecord.find_or_create_by(nct_id: nct_id, version: '2') { |r| r.content = {} }
        puts "\nDownloading: #{nct_id}"
        update_from_apiV2(record, nct_id)
      end
    end

    def self.download(nct_ids, version='2')
      nct_ids.each do |nct_id|
        case version
        when '2'
          record = StudyJsonRecord.find_by(nct_id: nct_id, version: version) || StudyJsonRecord.create(nct_id: nct_id, content: {}, version: version)
          update_from_apiV2(record, nct_id) 
          return record
        when '1'
          record = StudyJsonRecord.find_by(nct_id: nct_id, version: version) || StudyJsonRecord.create(nct_id: nct_id, content: {}, version: version)
          record.update_from_api
          record.reload
          return record
        else
          raise "Unknown version: #{version}"
        end
        puts "Study id: #{record.id}, study nct_id: #{record.nct_id}, version: #{record.version}"
      end
    end

    def self.update_from_apiV2(record, nct_id)
      data = nil
      response = nil
      attempts = 0
      begin
        attempts += 1
        print ".".green
        content = ClinicalTrialsApiV2.study(nct_id)
        record.update(content: content)

        return record
      rescue Faraday::ConnectionFailed
        return false if attempts > 5
        retry
      rescue JSON::ParserError
        return false if attempts > 5
        retry
      end
    end

    # return the studies that are not found in the database and the studies that were updated after we updated them
    def self.find_studies_to_update
      # get a list of all studies from clinicaltrials.gov
      studies = ClinicalTrialsApiV2.all

      # find all the studies that were updated at clinicaltrials.gov after we updated them
      current = Hash[StudyJsonRecord.where(version: '2').pluck(:nct_id, :updated_at)]
      changed = studies.select{|k| current[k[:nct_id]].nil? || current[k[:nct_id]] < DateTime.parse(k[:updated]) }.map{|k| k[:nct_id]}
    end
  end
