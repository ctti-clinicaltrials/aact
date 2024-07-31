class OutcomeMeasurement < StudyRelationship
  belongs_to :outcome
  belongs_to :result_group

  def self.update_result_group_ids(nct_ids)
    Rails.logger.info "updating result group ids for outcome measurements"


    updates = []
    measurements = where(nct_id: nct_ids)
    groups = ResultGroup.where(nct_id: nct_ids, result_type: "Outcome").index_by do |group|
      [group.nct_id, group.ctgov_group_code, group.outcome_id]
    end

    measurements.each do |measurement|
      group = groups[[measurement.nct_id, measurement.ctgov_group_code, measurement.outcome_id]]
      updates << { id: measurement.id, result_group_id: group.id } if group
    end

    import updates, on_duplicate_key_update: { conflict_target: [:id], columns: [:result_group_id] }  
  end
end
