class Link < StudyRelationship

  add_mapping do
    {
      table: :links,
      root: [:protocolSection, :referencesModule, :seeAlsoLinks],
      columns: [
        { name: :url, value: :url },
        { name: :description, value: :label }
      ]
    }
  end

end
