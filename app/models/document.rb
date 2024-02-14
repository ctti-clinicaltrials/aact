class Document < StudyRelationship

  add_mapping do
    {
      table: :documents,
      root: [:protocolSection, :referencesModule, :availIpds],
      columns: [
        { name: :document_id, value: :id },
        { name: :document_type, value: :type },
        { name: :url, value: :url },
        { name: :comment, value: :comment }
      ]
    }
  end

end
