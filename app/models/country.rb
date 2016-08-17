class Country < StudyRelationship

  def self.create_all_from(opts)
    countries = location_countries(opts) + removed_countries(opts)
    import(countries)
  end

  def self.location_countries(opts)
    opts[:xml].xpath('//location_countries').collect{|xml|
      new({:name=>xml.text.strip, :nct_id=>opts[:nct_id]})}
  end

  def self.removed_countries(opts)
    opts[:xml].xpath('//removed_countries').collect{|xml|
      new({:name=>xml.text.strip, :nct_id=>opts[:nct_id], :removed=>true})}
  end
end
