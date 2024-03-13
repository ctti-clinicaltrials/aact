class Sponsor < StudyRelationship
  
  add_mapping do
    [
      {
        table: :sponsors,
        root: [:protocolSection, :sponsorCollaboratorsModule, :leadSponsor],
        columns: [
          { name: :agency_class, value: :class },
          { name: :lead_or_collaborator, value: 'lead' },
          { name: :name, value: :name }
        ]
      },
      {
        table: :sponsors,
        root: [:protocolSection, :sponsorCollaboratorsModule, :collaborators],
        columns: [
          { name: :agency_class, value: :class },
          { name: :lead_or_collaborator, value: 'collaborator' },
          { name: :name, value: :name }
        ]
      }
    ]
  end  

end
