class OutcomeCount < StudyRelationship
  belongs_to :outcome
  belongs_to :result_group

  def self.update_result_group_ids(nct_ids)
    Rails.logger.info "updating result group ids for outcome counts"
    updates = []

    outcome_counts = where(nct_id: nct_ids)

    # find groups and index by composite key
    result_groups = ResultGroup.where(nct_id: nct_ids, result_type: "Outcome").index_by do |group|
       [group.nct_id, group.ctgov_group_code, group.outcome_id]
    end
    
    # find matching groups and build updates array
    outcome_counts.each do |outcome_count|
      # lookup group by composite key
      group = result_groups[[outcome_count.nct_id, outcome_count.ctgov_group_code, outcome_count.outcome_id]]
      updates << { id: outcome_count.id, result_group_id: group.id } if group
    end

    # update existing count records with result_group_id
    import updates, on_duplicate_key_update: { conflict_target: [:id], columns: [:result_group_id] }
  end
end
