class Sponsor < StudyRelationship
  scope :named, lambda {|agency| where("name LIKE ?", "#{agency}%" )}

  def self.create_all_from(opts)
    sponsors = leads(opts) + collaborators(opts)
    import(sponsors)
  end

  def self.leads(opts)
    opts[:xml].xpath("//lead_sponsor").collect{|xml|
      new.create_from({:xml=>xml,:type=>'lead',:nct_id=>opts[:nct_id]}) }
  end

  def self.collaborators(opts)
    opts[:xml].xpath("//collaborator").collect {|xml|
      new.create_from({:xml=>xml,:type=>'collaborator',:nct_id=>opts[:nct_id]}) }
  end

  def attribs
    {
      :nct_id => get_opt(:nct_id),
      :lead_or_collaborator => get_opt('type'),
      :agency_class => get('agency_class'),
      :name => get('agency'),
    }
  end

end
