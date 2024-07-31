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


  def self.set_outcome_results_group_ids(study_ids)
    Rails.logger.info "Setting Result Group IDs for Outcome Counts and Measurements"

    outcome_counts_updates = []
    outcome_counts = OutcomeCount.where(nct_id: study_ids)

    outcome_measurements_updates = []
    outcome_measurements = OutcomeMeasurement.where(nct_id: study_ids)

    groups = where(nct_id: study_ids, result_type: 'Outcome').index_by do |group|
      [group.nct_id, group.ctgov_group_code, group.outcome_id]
    end

    outcome_counts.each do |count|
      group = groups[[count.nct_id, count.ctgov_group_code, count.outcome_id]]
      outcome_counts_updates << { id: count.id, result_group_id: group.id } if group
    end

    outcome_measurements.each do |measurement|
      group = groups[[measurement.nct_id, measurement.ctgov_group_code, measurement.outcome_id]]
      outcome_measurements_updates << { id: measurement.id, result_group_id: group.id } if group
    end

    OutcomeCount.import outcome_counts_updates, on_duplicate_key_update: { conflict_target: [:id], columns: [:result_group_id] }
    OutcomeMeasurement.import outcome_measurements_updates, on_duplicate_key_update: { conflict_target: [:id], columns: [:result_group_id] }
  end
end