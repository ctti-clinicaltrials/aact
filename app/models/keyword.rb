class Keyword < StudyRelationship
  add_mapping do
    {
      table: :keywords,
      root: [:protocolSection, :conditionsModule, :keywords],
      columns: [
        {name: :name, value: nil},
        {name: :downcase_name, value: nil, convert_to: :downcase}
      ]
    }
  end
end
