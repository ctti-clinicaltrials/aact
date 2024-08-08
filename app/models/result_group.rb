class ResultGroup < StudyRelationship

  # has_many :reported_events
  # has_many :milestones
  # has_many :drop_withdrawals
  # has_many :baseline_counts
  # has_many :baseline_measures

  # has_many :outcome_counts
  # has_many :outcome_measurements
  # TODO: review analysis_groups
  # has_many :outcome_analysis_groups#, inverse_of: :result_group
  # has_many :outcome_analyses, :through => :outcome_analysis_groups

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
        requires: :outcomes, # TODO: review - this shouldn't be necessary
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

  def self.handle_outcome_result_groups_ids(nct_ids)
    Rails.logger.info "Handling Results Group IDs for Outcome Models"
    result_groups = fetch_outcome_groups_for(nct_ids)
    set_results_group_ids_for(OutcomeCount, nct_ids, result_groups)
    set_results_group_ids_for(OutcomeMeasurement, nct_ids, result_groups)
    set_outcome_analysis_group_ids(nct_ids, result_groups)
  end


  private

  def self.set_outcome_analysis_group_ids(nct_ids, result_groups)
    Rails.logger.info "Setting Outcome Analysis Group IDs"
    analyses = OutcomeAnalysis.where(nct_id: nct_ids).pluck(:id, :outcome_id).to_h
    groups = OutcomeAnalysisGroup.where(nct_id: nct_ids)

    updates = groups.map do | group |
      outcome_id = analyses[group.outcome_analysis_id]
      next unless outcome_id

      key = [group.nct_id, group.ctgov_group_code, outcome_id]
      result_group_id = result_groups[key]&.id
      { id: group.id, result_group_id: result_group_id } if result_group_id
    end.compact

    bulk_update(OutcomeAnalysisGroup, updates)
  end

  def self.set_results_group_ids_for(model, nct_ids, result_groups)
    Rails.logger.info "Setting Result Group IDs for #{model}"

    records = model.where(nct_id: nct_ids).select(:id, :nct_id, :ctgov_group_code, :outcome_id)
    updates = records.map do |record|
      key = [record.nct_id, record.ctgov_group_code, record.outcome_id]
      result_group_id = result_groups[key]&.id
      { id: record.id, result_group_id: result_group_id } if result_group_id
    end.compact

    bulk_update(model, updates)
  end


  # TODO: consider adding index for nct_id and result_type
  def self.fetch_outcome_groups_for(nct_ids)
    where(nct_id: nct_ids, result_type: "Outcome")
      .select(:id, :nct_id, :ctgov_group_code, :outcome_id)
      .index_by do |group|
      [group.nct_id, group.ctgov_group_code, group.outcome_id]
    end
  end

  def self.bulk_update(model, updates)
    model.import updates, on_duplicate_key_update: { conflict_target: [:id], columns: [:result_group_id] }
  end
end