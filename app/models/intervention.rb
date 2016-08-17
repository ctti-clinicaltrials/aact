class Intervention < StudyRelationship
  has_many :intervention_arm_group_labels, inverse_of: :intervention, autosave: true
  has_many :intervention_other_names, inverse_of: :intervention, autosave: true

  def self.top_level_label
    '//intervention'
  end

  def self.create_all_from(opts)
    objects=xml_entries(opts).collect{|xml|
      opts[:xml]=xml
      intervention = new.create_from(opts)
      intervention_arm_group_labels = InterventionArmGroupLabel.create_all_from(opts)
      intervention_other_names = InterventionOtherName.create_all_from(opts)

      intervention_arm_group_labels.each do |arm_group_label|
        intervention.intervention_arm_group_labels.build(arm_group_label)
      end

      intervention_other_names.each do |other_name|
        intervention.intervention_other_names.build(other_name)
      end

      intervention
    }.compact

    import(objects, recursive: true)
  end

  def attribs
    {
      :intervention_type=>get('intervention_type'),
      :name => get('intervention_name'),
      :description => get('description'),
    }
  end

  def other_names
    intervention_other_names
  end

  def type
    intervention_type
  end

end
