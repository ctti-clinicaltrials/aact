class OutcomeMeasurement < StudyRelationship
  belongs_to :outcome
  belongs_to :result_group

  def self.update_result_group_ids(nct_ids)
    puts "updating result group ids for outcome measurements"
    where(nct_id: nct_ids).find_each do |outcome_measurement|
      result_group = ResultGroup.find_by(nct_id: outcome_measurement.nct_id, ctgov_group_code: outcome_measurement.ctgov_group_code, outcome_id: outcome_measurement.outcome_id)
      if result_group
        outcome_measurement.update(result_group_id: result_group.id)
      end
    end
  end
end
