class StudyProcessor
    def self.process
      records = StudyJsonRecord.where('saved_study_at IS NULL OR updated_at > saved_study_at')
      records.each do |record|
      record.create_or_update_study if record.version == "1"
      StudyJsonRecord::ProcessorV2.new(record.content).process if record.version == "2"
      end
    end
end
    
