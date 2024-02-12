class Design < StudyRelationship
  add_mapping do
    {
      table: :design,
      root: [:protocolSection, :designModule],
      columns: [
        { name: :allocation, attribute: :allocation },
        { name: :intervention_model, attribute: :interventionModel },
        { name: :intervention_model_description, attribute: :interventionModelDescription },
        { name: :primary_purpose, attribute: ->(data) { extract_primary_purpose(data) } },
        { name: :masking, attribute: ->(data) { extract_masking(data) } },
        { name: :masking_description, attribute: :maskingDescription },
        { name: :subject_masked, attribute: ->(data) { masked?(data, 'PARTICIPANT') } },
        { name: :caregiver_masked, attribute: ->(data) { masked?(data, 'CARE_PROVIDER') } },
        { name: :investigator_masked, attribute: ->(data) { masked?(data, 'INVESTIGATOR') } },
        { name: :outcomes_assessor_masked, attribute: ->(data) { masked?(data, 'OUTCOMES_ASSESSOR') } }
      ]
    }
  end

  private

  def extract_primary_purpose(data)
    parsed_data = JSON.parse(data)
    parsed_data.dig('designInfo', 'primaryPurpose')
  end

  def extract_masking(data)
    parsed_data = JSON.parse(data)
    parsed_data.dig('designInfo', 'maskingInfo', 'masking')
  end

  def masked?(data, role)
    parsed_data = JSON.parse(data)
    masking_info = parsed_data.dig('designInfo', 'maskingInfo')
    return false unless masking_info.present?

    who_masked = masking_info['whoMasked']
    who_masked&.include?(role)
  end
end
