class OutcomeCount < StudyRelationship
  belongs_to :outcome
  belongs_to :result_group

  def self.update_result_group_ids(nct_ids)
    puts "updating result group ids for outcome counts"
    where(nct_id: nct_ids).find_each do |outcome_count|
      result_group = ResultGroup.find_by(nct_id: outcome_count.nct_id, ctgov_group_code: outcome_count.ctgov_group_code, outcome_id: outcome_count.outcome_id)
      if result_group
        outcome_count.update(result_group_id: result_group.id)
      end
    end
  end
end
