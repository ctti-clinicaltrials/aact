class InterventionArmGroupLabel < StudyRelationship
  belongs_to :intervention, inverse_of: :intervention_arm_group_labels, autosave: true

  def self.top_level_label
    'arm_group_label'
  end

  def self.create_all_from(opts)
    objects = super
    objects.map(&:attributes)
  end

  def attribs
    {:label=>opts[:xml].text}
  end

end
