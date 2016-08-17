class DesignGroup < StudyRelationship

  def self.top_level_label
    '//arm_group'
  end

  def self.create_all_from(opts)
    objects = super
    import(objects)
  end

  def attribs
    {
      :group_type => get('arm_group_type'),
      :title => get('arm_group_label'),
      :description => get('description'),
    }
  end

end
