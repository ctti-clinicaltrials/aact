class Facility < StudyRelationship
  has_many :facility_contacts
  has_many :facility_investigators

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
          filter: ->(contact) { contact['role'] =~ /investigator|study.chair/i },
          columns: [
            { name: :role, value: :role },
            { name: :name, value: :name },
          ]
        },
        {
          table: :facility_contacts,
          root: [:contacts],
          filter: ->(contact) { contact['role'] !~ /investigator|study.chair/i },
          columns: [
            { name: :contact_type, value: ->(entry,index){ index == 0 ? 'primary' : 'backup' }},
            { name: :name, value: :name },
            { name: :email, value: :email },
            { name: :phone, value: :phone },
            { name: :phone_extension, value: :phoneExt },
          ]
        }
      ]
    }
  end
end
