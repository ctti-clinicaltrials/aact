class FacilityInvestigator < StudyRelationship
  belongs_to :facility, autosave: true

  def self.create_all_from(opts)
    get_investigators(opts)
  end

  def self.get_investigators(opts)
    opts[:location].xpath('investigator').collect{|xml|
      new.create_from({:xml=>xml,:nct_id=>opts[:nct_id]})
    }
  end

  def attribs
    {
      :nct_id => get_opt('nct_id'),
      :name => get('last_name'),
      :role => get('role'),
      :facility => get_opt('facility'),
    }
  end

end

