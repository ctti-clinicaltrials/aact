class Link < StudyRelationship

  def self.top_level_label
    '//link'
  end

  def self.create_all_from(opts)
    objects = super
    import(objects)
  end

  def attribs
    {:url=>get('url'),
     :description => get('description')}
  end

end
