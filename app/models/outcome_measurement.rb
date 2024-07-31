class OutcomeMeasurement < StudyRelationship
  belongs_to :outcome
  belongs_to :result_group
end
