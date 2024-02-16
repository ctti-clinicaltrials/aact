class Condition < StudyRelationship

  add_mapping do
    {
      table: :conditions,
      root: [:protocolSection, :conditionsModule, :conditions],
      columns: [
        { name: :name, value: :conditions },
        { name: :downcase_name, value: :conditions.try(:downcase) }
      ]
    }
  end

end
