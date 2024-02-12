class BrowseCondition < StudyRelationship
  add_mapping do
    [
      {
        table: :browse_conditions,
        root: [:derivedSection, :conditionBrowseModule, :meshes],
        columns: [
          { name: :mesh_term, value: :term},
          { name: :downcase_mesh_term, value: :term, convert_to: :downcase },
          { name: :mesh_type, value: 'mesh-list' }
        ]
      },
      {
        table: :browse_conditions,
        root: [:derivedSection, :conditionBrowseModule, :ancestors],
        columns: [
          { name: :mesh_term, value: :term},
          { name: :downcase_mesh_term, value: :term, convert_to: :downcase },
          { name: :mesh_type, value: 'mesh-ancestor' }
        ]
      }
    ]
  end
end
