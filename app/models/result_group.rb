class ResultGroup < StudyRelationship

  has_many :reported_events
  has_many :milestones
  has_many :drop_withdrawals
  has_many :baseline_counts
  has_many :baseline_measures
  has_many :outcome_measurements

  has_one :outcome_counts
  has_many :outcome_analysis_groups, inverse_of: :result_group
  has_many :outcome_analyses, :through => :outcome_analysis_groups

  belongs_to :outcome, optional: true

  add_mapping do
    [
      {
        table: :result_groups,
        root: [:resultsSection, :baselineCharacteristicsModule, :groups],
        index: [:ctgov_group_code, :result_type],
        # requires: :outcomes,
        unique: true,
        columns: [
          { name: :ctgov_group_code, value: :id },
          { name: :result_type, value: 'Baseline' },
          { name: :title, value: :title },
          { name: :description, value: :description },
        ]
      },
      # {
      #   table: :result_groups,
      #   root: [:resultsSection, :outcomeMeasuresModule, :outcomeMeasures],
      #   flatten: [:groups],
      #   index: [:ctgov_group_code, :result_type],
      #   unique: true,
      #   columns: [
      #     { name: :ctgov_group_code, value: :id },
      #     { name: :result_type, value: 'Outcome' },
      #     { name: :title, value: :title },
      #     { name: :description, value: :description },
      #   ]
      # },
      {
        table: :result_groups,
        root: [:resultsSection, :participantFlowModule, :groups],
        index: [:ctgov_group_code, :result_type], 
        # requires: :outcomes,
        unique: true,
        columns: [
          { name: :ctgov_group_code, value: :id },
          { name: :result_type, value: 'Participant Flow' },
          { name: :title, value: :title },
          { name: :description, value: :description },
        ]
      },
      {
        table: :result_groups,
        root: [:resultsSection, :adverseEventsModule, :eventGroups],
        index: [:ctgov_group_code, :result_type],
        # requires: :outcomes,
        unique: true,
        columns: [
          { name: :ctgov_group_code, value: :id },
          { name: :result_type, value: 'Reported Event' },
          { name: :title, value: :title },
          { name: :description, value: :description }
        ]
      }
    ]
  end
end