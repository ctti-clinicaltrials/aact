class DesignOutcome < StudyRelationship

  scope :outcomes_count_by_type, -> (nct_ids) {
    where(nct_id: nct_ids).group(:nct_id, :outcome_type).count
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

  def self.count_outcomes_by_type_for(nct_ids)
    counts = DesignOutcome.outcomes_count_by_type(nct_ids)

    nct_ids.each_with_object({}) do |nct_id, organized_counts|
      organized_counts[nct_id] = {
        primary: counts[[nct_id, 'primary']],
        secondary: counts[[nct_id, 'secondary']],
        other: counts[[nct_id, 'other']]
      }
    end
  end
end
