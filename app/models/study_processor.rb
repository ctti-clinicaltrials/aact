class StudyProcessor
    def self.process
        StudyJsonRecord.all.each do |study| 
            if study.updated_at > saved_study_at || saved_study_at == nil
              if study.version == 1
                study.create_or_update_study
              elsif study.version == 2 
                ProcessorV2.new(study.content).process
                # StudyDownloader.update_from_apiV2(study, study.nct_id)
              end
            end  
        end
    end
end