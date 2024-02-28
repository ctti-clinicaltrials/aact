class BrowseIntervention < StudyRelationship

  add_mapping do
    [
      {
        table: :browse_interventions,
        root: [:derivedSection, :interventionBrowseModule, :meshes],
        columns: [
          { name: :mesh_term, value: :term},
          { name: :downcase_mesh_term, value: :term, convert_to: :downcase },
          { name: :mesh_type, value: 'mesh-list' }
        ]
      },
      {
        table: :browse_interventions,
        root: [:derivedSection, :interventionBrowseModule, :ancestors],
        columns: [
          { name: :mesh_term, value: :term},
          { name: :downcase_mesh_term, value: :term, convert_to: :downcase },
          { name: :mesh_type, value: 'mesh-ancestor' }
        ]
      },
      {
        table: :browse_interventions,
        root: [:derivedSection, :interventionBrowseModule, :browseLeaves],
        columns: [
          { name: :mesh_term, value: :term},
          { name: :downcase_mesh_term, value: :term, convert_to: :downcase },
          { name: :mesh_type, value: 'mesh-browseLeave' }
        ]
      },
      {
        table: :browse_interventions,
        root: [:derivedSection, :interventionBrowseModule, :browseBranches],
        columns: [
          { name: :mesh_term, value: :term},
          { name: :downcase_mesh_term, value: :term, convert_to: :downcase },
          { name: :mesh_type, value: 'mesh-browseBranch' }
        ]
      }
    ]
  end

end
