class StudyProcessor
    def self.process
      saved_nil = []
      StudyJsonRecord.all.each do |study|
        if study.saved_study_at.nil? 
          saved_nil.push(study)
        elsif (study.updated_at > study.saved_study_at) && !study.updated_at.nil?
          saved_nil.push(study)
        end
      end

      saved_nil.each do |record|
          record.create_or_update_study if record.version == "1"
          StudyJsonRecord::ProcessorV2.new(record.content).process if record.version == "2"
      end
        
    end
end