class InterventionOtherName < StudyRelationship
  belongs_to :intervention, inverse_of: :intervention_other_names, autosave: true

  def self.top_level_label
    'other_name'
  end

  def self.create_all_from(opts)
    objects = super
    objects.map(&:attributes)
  end

  def attribs
    {:name=>opts[:xml].text}
  end

end
