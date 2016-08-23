class ResultContact < StudyRelationship

  def self.top_level_label
    '//point_of_contact'
  end

  def self.create_all_from(opts)
    objects = super
    import(objects)
  end

  def attribs
    {
      :name => get('name_or_title'),
      :organization => get('organization'),
      :phone => get('phone'),
      :email => get('email'),
    }
  end

end
