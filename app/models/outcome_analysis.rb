class OutcomeAnalysis < StudyRelationship
  belongs_to :outcome
  has_many   :outcome_analysis_groups
end
