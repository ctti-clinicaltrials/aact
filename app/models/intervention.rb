class Intervention < StudyRelationship
  has_many :intervention_arm_group_labels
  has_many :intervention_other_names

  def self.top_level_label
    '//intervention'
  end

  def attribs
    {
     :intervention_type=>get('intervention_type'),
     :name => get('intervention_name'),
     :description => get('description'),
     :intervention_arm_group_labels => InterventionArmGroupLabel.create_all_from(opts),
     :intervention_other_names => InterventionOtherName.create_all_from(opts)
    }
  end

	def other_names
		intervention_other_names
	end

	def type
		intervention_type
	end

end
