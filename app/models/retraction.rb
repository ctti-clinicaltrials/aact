class Retraction < StudyRelationship
  belongs_to :study_reference, foreign_key: :reference_id
end
