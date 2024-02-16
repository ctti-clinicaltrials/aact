class Condition < StudyRelationship

  def conditions_data
    return unless protocol_section

    nct_id = protocol_section.dig('identificationModule', 'nctId')

    conditions_module = protocol_section['conditionsModule']
    return unless conditions_module

    conditions = conditions_module.dig('conditions')
    return unless conditions

    collection = []
    conditions.each do |condition|
      collection << { nct_id: nct_id, name: condition, downcase_name: condition.try(:downcase) }
    end
    collection
  end

end
