class Country < StudyRelationship

  def self.create_all_from(opts)
    countries = location_countries(opts) + removed_countries(opts)
    Country.import(countries)
  end

  def self.location_countries(opts)
    opts[:xml].xpath('//location_countries').collect{|xml|
      Country.new({:name=>xml.text.strip, :nct_id=>opts[:nct_id]})}
  end

  def self.removed_countries(opts)
    opts[:xml].xpath('//removed_countries').collect{|xml|
      puts xml
      Country.new({:name=>xml.text.strip, :nct_id=>opts[:nct_id], :removed=>'true'})}
  end
end
