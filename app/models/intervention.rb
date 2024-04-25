class Intervention < StudyRelationship
  has_many :intervention_other_names, inverse_of: :intervention, autosave: true
  has_many :design_group_interventions,  inverse_of: :intervention, autosave: true
  has_many :design_groups, :through => :design_group_interventions

  add_mapping do
    {
      table: :interventions,
      root: [:protocolSection, :armsInterventionsModule, :interventions],
      requires: [:design_groups],
      columns: [
        { name: :intervention_type, value: :type },
        { name: :name, value: :name },
        { name: :description, value: :description }
      ],
      children: [
        {
          table: :intervention_other_names,
          root: [:otherNames],
          columns: [
            { name: :name, value: nil }
          ]
        },
        {
          table: :design_group_interventions,
          root: [:armGroupLabels],
          columns: [
            { name: :design_group_id, value: reference(:design_groups)[nil] },
          ]
        }
      ]
    }
  end
end