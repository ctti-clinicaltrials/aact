class Country < StudyRelationship

  add_mapping do
    [
      {
        table: :countries,
        root: [:protocolSection, :contactsLocationsModule, :locations],
        columns: [
          { name: :name, value: :country },
          { name: :removed, value: false }
        ]
      },
      {
        table: :countries,
        root: [:derivedSection, :miscInfoModule, :removedCountries],
        columns: [
          { name: :name, value: nil },
          { name: :removed, value: true }
        ]
      }
    ]
  end  

end