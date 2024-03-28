class StudyReference < StudyRelationship  
	add_mapping do
    {
      table: :study_references,
      root: [:protocolSection, :referencesModule, :references],
      columns: [
        { name: :pmid, value: :pmid},
        { name: :reference_type, value: :type},
        { name: :citation, value: :citation}
      ]
    }
  end
end