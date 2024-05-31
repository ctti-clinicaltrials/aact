class InterventionOtherName < StudyRelationship
  belongs_to :intervention, inverse_of: :intervention_other_names

end
