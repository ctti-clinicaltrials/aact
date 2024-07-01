class DesignOutcome < StudyRelationship
  
  scope :primary_outcomes, -> (nct_ids) {
    where(nct_id: nct_ids, outcome_type: "primary").group(:nct_id).count
  }

  scope :secondary_outcomes, -> (nct_ids) {
    where(nct_id: nct_ids, outcome_type: "secondary").group(:nct_id).count
  }

  scope :other_outcomes, -> (nct_ids) {
    where(nct_id: nct_ids, outcome_type: "other").group(:nct_id).count
  }

  add_mapping do
    [
      {
        table: :design_outcomes,
        root: [:protocolSection, :outcomesModule, :primaryOutcomes],
        columns: [
          { name: :outcome_type , value: "primary" },
          { name: :measure, value: :measure },
          { name: :time_frame, value: :timeFrame },
          { name: :description, value: :description }
        ]
      },
      {
        table: :design_outcomes,
        root: [:protocolSection, :outcomesModule, :secondaryOutcomes],
        columns: [
          { name: :outcome_type , value: "secondary" },
          { name: :measure, value: :measure },
          { name: :time_frame, value: :timeFrame },
          { name: :description, value: :description }
        ]
      },
      {
        table: :design_outcomes,
        root: [:protocolSection, :outcomesModule, :otherOutcomes],
        columns: [
          { name: :outcome_type , value: "other" },
          { name: :measure, value: :measure },
          { name: :time_frame, value: :timeFrame },
          { name: :description, value: :description }
        ]
      }
    ]
  end
end
