class InterventionOtherName < StudyRelationship
  belongs_to :intervention, inverse_of: :intervention_other_names, autosave: true

  add_mapping do

  # def intervention_other_names_data(intervention)
  #   return unless intervention

  #   other_names = intervention.dig('InterventionOtherNameList', 'InterventionOtherName')
  #   return unless other_names

  #   collection = []
  #   other_names.each do |name|
  #     collection << { nct_id: nct_id, intervention_id: nil, name: name }
  #   end
  #   collection
  # end

    {
      table: :conditions,
      root: [:protocolSection, :armsInterventionsModule, :interventions],
      columns: [
        { name: :intervention_id, value: nil },
        { name: :name, value: :otherNames }
      ]
    }
  end

end
