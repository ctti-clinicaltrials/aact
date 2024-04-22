class OutcomeAnalysis < StudyRelationship
  belongs_to :outcome, inverse_of: :outcome_analyses, autosave: true
  has_many   :outcome_analysis_groups, inverse_of: :outcome_analysis, autosave: true
  has_many   :result_groups, :through => :outcome_analysis_groups
end
