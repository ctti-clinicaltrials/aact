class OutcomeAnalysisGroup < StudyRelationship
  belongs_to :outcome_analysis, inverse_of: :outcome_analysis_groups, autosave: true
  belongs_to :result_group,     inverse_of: :outcome_analysis_groups, autosave: true

end
