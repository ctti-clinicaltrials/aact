class Facility < StudyRelationship
  has_many :facility_contacts, autosave: true
  has_many :facility_investigators, autosave: true

  add_mapping do
    {
      table: :facilities,
      root: [:protocolSection, :contactsLocationsModule, :locations],
      columns: [
        { name: :status, value: :status },
        { name: :name, value: :facility },
        { name: :city, value: :city },
        { name: :state, value: :state },
        { name: :zip, value: :zip },
        { name: :country, value: :country },
      ],
      children: [
        {
          table: :facility_investigators,
          root: [:contacts],
          # filter: ->(contact) { contact['role'] =~ /investigator|study.chair/i },
          columns: [
            { name: :role, value: :role },
            { name: :name, value: :name },
          ]
        }
      ]
    }
  end
end
