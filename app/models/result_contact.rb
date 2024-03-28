class ResultContact < StudyRelationship

  add_mapping do
    {
      table: :result_contacts,
      root: [:resultsSection, :moreInfoModule, :pointOfContact],
      columns: [
        { name: :extension, value: :phoneExt },
        { name: :phone, value: :phone },
        { name: :name, value: :title },
        { name: :organization, value: :organization },
        { name: :email, value: :email }
      ]
    }
  end

end
