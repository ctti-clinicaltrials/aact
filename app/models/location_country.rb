class LocationCountry < StudyRelationship

  def self.top_level_label
    '//location_countries'
  end

  def self.create_all_from(opts)
    location_countries = xml_entries(opts).children.collect{|xml|
      opts[:xml]=xml
      create_from(opts) if xml.name='country' and !trim(xml.text).blank?
    }.compact

    LocationCountry.import(location_countries)
  end

  def attribs
    {:name=>xml.text}
  end

end
