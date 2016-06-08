class SecondaryId < StudyRelationship

  def self.top_level_label
    '//secondary_id'
  end

  def self.create_all_from(opts)
    objects = super
    SecondaryId.import(objects)
  end

  def attribs
    {:secondary_id=>xml.inner_html}
  end

end
