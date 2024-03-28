class BriefSummary < StudyRelationship
  add_mapping do
    {
      table: :brief_summaries,
      root: [:protocolSection, :descriptionModule],
      columns: [
        { name: :description, value: :briefSummary }
      ]
    }
  end
end
