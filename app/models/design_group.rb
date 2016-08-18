class DesignGroup < StudyRelationship
  has_many :design_group_interventions,  inverse_of: :design_group, autosave: true
  has_many :interventions, :through => :design_group_interventions

  def self.top_level_label
    '//arm_group'
  end

  def self.xcreate_all_from(opts)
    objects=xml_entries(opts).collect{|xml|
      opts[:xml]=xml
      create.create_from(opts)
    }.compact
    objects
  end

  def self.create_all_from(opts)
    objects = super
    import(objects, recursive: true)
    return objects
  end

  def attribs
    {
      :group_type => get('arm_group_type'),
      :title => get('arm_group_label'),
      :description => get('description'),
    }
  end

end
