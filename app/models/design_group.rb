class DesignGroup < StudyRelationship
  has_many :design_group_interventions,  inverse_of: :design_group, autosave: true
  has_many :interventions, :through => :design_group_interventions

  add_mapping do
    {
      table: :design_groups,
      root: [:protocolSection, :armsInterventionsModule, :armGroups],
      columns: [
        { name: :group_type, value: :type },
        { name: :title, value: :label },
        { name: :description, value: :description }
      ]
    }
  end
end
