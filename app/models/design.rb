class Design < StudyRelationship
  add_mapping do
    {
      table: :designs,
      root: [:protocolSection, :designModule, :designInfo],
      columns: [
        { name: :allocation, value: :allocation },
        { name: :observational_model, value: :observationalModel },
        { name: :intervention_model, value: :interventionModel },
        { name: :intervention_model_description, value: :interventionModelDescription },
        { name: :primary_purpose, value: :primaryPurpose },
        { name: :time_perspective, value: :timePerspective},
        { name: :masking, value: [:maskingInfo, :masking] },
        { name: :masking_description, value: [:maskingInfo, :maskingDescription] },
        { name: :subject_masked, value: ->(val) { val.dig('maskingInfo', 'whoMasked').include?('PARTICIPANT')}},
        { name: :caregiver_masked, value: ->(val) { val.dig('maskingInfo', 'whoMasked').include?('CARE_PROVIDER')}},
        { name: :investigator_masked, value: ->(val) { val.dig('maskingInfo', 'whoMasked').include?('INVESTIGATOR')}},
        { name: :outcomes_assessor_masked, value: ->(val) { val.dig('maskingInfo', 'whoMasked').include?('OUTCOME_ACCESSOR')}},
      ]
    }
  end
end