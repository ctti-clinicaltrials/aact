class Condition < StudyRelationship

  add_mapping do
    {
      table: :conditions,
      root: [:protocolSection, :conditionsModule, :conditions],
      columns: [
        { name: :name, value: nil },
        { name: :downcase_name, value: nil, convert_to: :downcase }
      ]
    }
  end

end
