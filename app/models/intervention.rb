class Intervention < StudyRelationship
  has_many :intervention_other_names, inverse_of: :intervention, autosave: true
  has_many :design_group_interventions,  inverse_of: :intervention, autosave: true
  has_many :design_groups, :through => :design_group_interventions

  def self.top_level_label
    '//intervention'
  end

  def self.create_all_from(opts)
    objects=xml_entries(opts).collect{|xml|
      opts[:xml]=xml
      opts[:group_titles]=xml.xpath('arm_group_label')
      new.create_from(opts)
    }.compact

    import(objects, recursive: true)
    objects
  end

  def attribs
    {
      :intervention_type=>get('intervention_type'),
      :name => get('intervention_name'),
      :description => get('description'),
      :intervention_other_names => InterventionOtherName.create_all_from(opts.merge(:intervention=>self)),
      :design_group_interventions => DesignGroupIntervention.create_all_from(opts.merge(:intervention=>self)),
    }
  end

end
