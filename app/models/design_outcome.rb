class DesignOutcome < StudyRelationship
  add_mapping do
    [
      {
        table: :design_outcomes,
        root: [:protocolSection, :outcomesModule, :primaryOutcomes],
        columns: [
          { name: :outcome_type , value: "primaryOutcomes" },
          { name: :measure, value: :measure },
          { name: :time_frame, value: :timeFrame },
          { name: :description, value: :description }
        ]
      },
      {
        table: :design_outcomes,
        root: [:protocolSection, :outcomesModule, :secondaryOutcomes],
        columns: [
          { name: :outcome_type , value: "secondaryOutcomes" },
          { name: :measure, value: :measure },
          { name: :time_frame, value: :timeFrame },
          { name: :description, value: :description }
        ]
      },
      {
        table: :design_outcomes,
        root: [:protocolSection, :outcomesModule, :otherOutcomes],
        columns: [
          { name: :outcome_type , value: "otherOutcomes" },
          { name: :measure, value: :measure },
          { name: :time_frame, value: :timeFrame },
          { name: :description, value: :description }
        ]
      }
    ]
  end
end
