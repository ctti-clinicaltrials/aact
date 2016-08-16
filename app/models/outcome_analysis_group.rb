class OutcomeAnalysisGroup < StudyRelationship
  extend FastCount
  belongs_to :outcome_analysis, inverse_of: :outcome_analysis_groups, autosave: true
  belongs_to :result_group,     inverse_of: :outcome_analysis_groups, autosave: true

  def self.create_all_from(hash)
    return [] if hash[:groups].empty?
    oa=hash[:outcome_analysis]
    hash[:group_ids].collect{|group_id|
      group=hash[:groups].select{|g|g.ctgov_group_code==group_id}.first
      new({:outcome_analysis=>oa,:ctgov_group_code=>group_id,:result_group=>group})
    }
  end
end
