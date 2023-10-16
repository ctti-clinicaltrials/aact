class StudyDownloader
    def self.download(nct_ids)
      
      nct_ids.each do |nct_id|
        record = StudyJsonRecord.find_by(nct_id: nct_id) || StudyJsonRecord.create(nct_id: nct_id, content: {})
        update_from_apiV2(record, nct_id)
        puts "Study id: #{record.id}, study nct_id: #{record.nct_id}, version: #{record.version}"
      end
      # example for testing ['NCT02071602', 'NCT00430612', 'NCT00785954', 'NCT00103350', 'NCT03445728', 'NCT03649711']

    end

    
    def self.update_from_apiV2(record, nct_id)
      data = nil
      response = nil
      attempts = 0
      begin
        attempts += 1
        s = Time.now
        body = Faraday.get("https://clinicaltrials.gov/api/v2/studies/#{nct_id}").body
        record.update(content: JSON.parse(body), version: "2")
      rescue Faraday::ConnectionFailed
        return false if attempts > 5
        retry
      rescue JSON::ParserError
        return false if attempts > 5
        retry
      end
    end
  
  end
