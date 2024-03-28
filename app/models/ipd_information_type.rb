class IpdInformationType < StudyRelationship

  add_mapping do
    {
      table: :ipd_information_types,
      root: [:protocolSection, :ipdSharingStatementModule, :infoTypes],
      columns: [
        { name: :name, value: nil }
      ]
    }
  end

end
