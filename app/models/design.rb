class Design < StudyRelationship
  add_mapping do
    {
      table: :design,
      root: [:protocolSection, :designModule, :designInfo],
      columns: [
        { name: :allocation, value: :allocation },
        { name: :intervention_model, value: :interventionModel },
        { name: :intervention_model_description, value: :interventionModelDescription },
        { name: :primary_purpose, value: :primaryPurpose },
        { name: :masking, value: ->(design) { design.masking } },
        { name: :masking_description, value: ->(design) { design.masking_description } },
        { name: :subject_masked, value: 'maskingInfo.whoMasked', mask_role: 'PARTICIPANT' },
        { name: :caregiver_masked, value: 'maskingInfo.whoMasked', mask_role: 'CARE_PROVIDER' },
        { name: :investigator_masked, value: 'maskingInfo.whoMasked', mask_role: 'INVESTIGATOR' },
        { name: :outcomes_assessor_masked, value: 'maskingInfo.whoMasked', mask_role: 'OUTCOMES_ASSESSOR' }
      ]
    }
  end
end