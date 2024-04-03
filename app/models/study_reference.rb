class StudyReference < StudyRelationship
  has_many :retractions, foreign_key: :reference_id 
  add_mapping do
    {
      table: :study_references,
      root: [:protocolSection, :referencesModule, :references],
      columns: [
        { name: :pmid, value: :pmid },
        { name: :reference_type, value: :type },
        { name: :citation, value: :citation }
      ],
      children: [
        {
          table: :retractions,
          root: [:retractions],
          columns: [
            { name: :pmid, value: :pmid },
            { name: :source, value: :source }
          ]
        }
      ]
    }
  end
end
