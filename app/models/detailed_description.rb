class DetailedDescription < StudyRelationship
  add_mapping do
    {
      table: :detailed_descriptions,
      root: [:protocolSection, :descriptionModule],
      columns: [
        { name: :description, value: :detailedDescription }
      ]
    }
  end
end
