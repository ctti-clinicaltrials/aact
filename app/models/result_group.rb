class ResultGroup < StudyRelationship

  has_many :reported_events, autosave: true
  has_many :milestones, autosave: true
  has_many :drop_withdrawals, autosave: true
  has_many :baseline_counts, autosave: true
  has_many :baseline_measures, autosave: true
  has_many :outcome_counts, autosave: true
  has_many :outcome_measurements, autosave: true
  has_many :outcome_analysis_groups, inverse_of: :result_group, autosave: true
  has_many :outcome_analyses, :through => :outcome_analysis_groups

  add_mapping do
    [
      {
        table: :result_groups,
        root: [:resultsSection, :baselineCharacteristicsModule, :groups],
        index: [:ctgov_group_code, :result_type], 
        columns: [
          { name: :ctgov_group_code, value: :id },
          { name: :result_type, value: 'Baseline' },
          { name: :title, value: :title },
          { name: :description, value: :description },
        ]
      },
      {
        table: :result_groups,
        root: [:resultsSection, :participantFlowModule, :groups],
        index: [:ctgov_group_code, :result_type], 
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
