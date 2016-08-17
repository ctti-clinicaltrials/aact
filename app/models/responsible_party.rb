class ResponsibleParty < StudyRelationship

  def self.top_level_label
    '//responsible_party'
  end

  def self.create_all_from(opts)
    objects = super
    import(objects)
  end

  def attribs
    {
      :responsible_party_type => get('responsible_party_type'),
      :affiliation => get('investigator_affiliation'),
      :organization => get('organization'),
      :title => get('investigator_title'),
      :name => get_name,
    }
  end

  def get_name
    n=get('investigator_full_name')
    !n.blank? ? n : get('name_title')
  end

end
