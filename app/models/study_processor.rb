class StudyProcessor
    def self.process
        StudyJsonRecord.all.each do |study| 
            if study.updated_at > saved_study_at || saved_study_at == nil
              if study.version == 1
                study.create_or_update_study
              elsif study.version == 2 
                
              end
            end  
        end
    end
end