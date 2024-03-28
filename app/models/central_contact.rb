class CentralContact < StudyRelationship
  add_mapping do
    {
      table: :central_contacts,
      root: [:protocolSection, :contactsLocationsModule, :centralContacts],
      columns: [
        { name: :contact_type, value: ->(val, index) { index == 0 ? 'primary' : 'backup' } },
        { name: :name, value: :name },
        { name: :phone, value: :phone },
        { name: :email, value: :email },
        { name: :phone_extension, value: :phoneExt },
        { name: :role, value: :role }
      ]
    }
  end
end