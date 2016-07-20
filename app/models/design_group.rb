class DesignGroup < StudyRelationship

  def self.top_level_label
    '//arm_group'
  end

  def self.create_all_from(opts)
    objects = super
    DesignGroup.import(objects)
  end

  def attribs
    {
      :ctgov_group_id => get_attribute('group_id'),
      :group_type => get('arm_group_type'),
      :title => get('arm_group_label'),
      :description => get('description'),
    }
  end

  def type
    group_type
  end

end
