class OverallOfficial < StudyRelationship

  add_mapping do
    {
      table: :overall_officials,
      root: [:protocolSection, :contactsLocationsModule, :overallOfficials],
      columns: [
        { name: :name, value: :name },
        { name: :affiliation, value: :affiliation },
        { name: :role, value: :role }
      ]
    }
  end

end
