class StudyDownloader
    def self.download(nct_ids)
      
      nct_ids.each do |nct_id|
        record = StudyJsonRecord.find_by(nct_id: nct_id) || StudyJsonRecord.create(nct_id: nct_id, content: {})
        record.update_from_api
        puts "Study id: #{record.id}, study nct_id: #{record.nct_id}, version: #{record.version}"
      end

    end
  end
