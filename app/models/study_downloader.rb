class StudyDownloader
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
        s = Time.now
        content = ClinicalTrialsApiV2.study(nct_id)
        record.update(content: content, version: "2")
        return record
      rescue Faraday::ConnectionFailed
        return false if attempts > 5
        retry
      rescue JSON::ParserError
        return false if attempts > 5
        retry
      end
    end
  
  end
