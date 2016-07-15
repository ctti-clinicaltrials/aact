class StudyWithRelatedRecordsSerializer < StudySerializer
  
    def attributes
      super.merge({
        brief_summary: object.brief_summary.attributes,
        design: object.design.attributes,
        detailed_description: object.detailed_description.attributes,
        eligibility: object.eligibility.attributes,
        participant_flow: object.participant_flow.attributes,
        result_detail: object.result_detail.attributes
      })
    end

    def root
      'study'
    end
end
