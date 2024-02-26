class Intervention < StudyRelationship
  has_many :intervention_other_names, inverse_of: :intervention, autosave: true
  has_many :design_group_interventions,  inverse_of: :intervention, autosave: true
  has_many :design_groups, :through => :design_group_interventions

  add_mapping do
    {
      table: :interventions,
      root: [:protocolSection, :armsInterventionsModule, :interventions],
      columns: [
        { name: :intervention_type, value: :type },
        { name: :name, value: :name },
        { name: :description, value: :description }
      ]
    }
  end
end