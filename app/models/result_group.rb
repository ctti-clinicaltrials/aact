class ResultGroup < StudyRelationship

  has_many :reported_events
  has_many :milestones
  has_many :drop_withdrawals
  has_many :baseline_counts
  has_many :baseline_measures

  has_many :outcome_counts
  has_many :outcome_measurements
  # TODO: review analysis_groups
  has_many :outcome_analysis_groups, inverse_of: :result_group
  has_many :outcome_analyses, :through => :outcome_analysis_groups

  belongs_to :outcome, optional: true

  add_mapping do
    [
      {
        table: :result_groups,
        root: [:resultsSection, :baselineCharacteristicsModule, :groups],
        index: [:ctgov_group_code, :result_type],
        # requires: :outcomes, # review this
        unique: true,
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
        # requires: :outcomes,  # review this
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
        # outcomes should be loaded first to avoid double loading of reported events
        requires: :outcomes,
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


  def self.set_outcome_results_group_ids(nct_ids)
    Rails.logger.info "Setting Result Group IDs for Outcome Counts and Measurements"

    groups = fetch_outcome_groups_for(nct_ids)

    outcome_counts_updates = prepare_updates_for(OutcomeCount, nct_ids, groups)
    outcome_measurements_updates = prepare_updates_for(OutcomeMeasurement, nct_ids, groups)

    bulk_update(OutcomeCount, outcome_counts_updates)
    bulk_update(OutcomeMeasurement, outcome_measurements_updates)
  end

  private

  # TODO: consider adding index for nct_id and result_type
  def self.fetch_outcome_groups_for(nct_ids)
    where(nct_id: nct_ids).index_by do |group|
      [group.nct_id, group.ctgov_group_code, group.outcome_id]
    end
  end

  def self.prepare_updates_for(model, nct_ids, groups)
    updates = []

    records = model.where(nct_id: nct_ids)
    records.each do |record|
      index = [record.nct_id, record.ctgov_group_code, record.outcome_id]
      group = groups[index]
      updates << { id: record.id, result_group_id: group.id } if group
    end
    updates
  end


  def self.bulk_update(model, updates)
    model.import updates, on_duplicate_key_update: { conflict_target: [:id], columns: [:result_group_id] }
  end
end