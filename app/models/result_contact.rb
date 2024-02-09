class ResultContact < StudyRelationship

  def self.top_level_label
    '//point_of_contact'
  end

  add_mapping do
    {
      table: :result_contacts,
      root: [:resultsSection, :moreInfoModule, :pointOfContact],
      columns: [
        { name: :ext, value: :phoneExt },
        { name: :phone, value: :phone },
        { name: :name, value: :title },
        { name: :organization, value: :organization },
        { name: :email, value: :email }
      ]
    }
  end

end
