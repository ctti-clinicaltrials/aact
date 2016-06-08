class Sponsor < StudyRelationship
  scope :named, lambda {|agency| where("agency LIKE ?", "#{agency}%" )}

  def self.create_all_from(opts)
    sponsors = leads(opts) + collaborators(opts)
    Sponsor.import(sponsors)
  end

  def self.leads(opts)
    opts[:xml].xpath("//lead_sponsor").collect{|xml|
      Sponsor.new.create_from({:xml=>xml,:type=>'lead',:nct_id=>opts[:nct_id]}) }
  end

  def self.collaborators(opts)
    opts[:xml].xpath("//collaborator").collect {|xml|
      Sponsor.new.create_from({:xml=>xml,:type=>'collaborator',:nct_id=>opts[:nct_id]}) }
  end

  def attribs
    {
      :nct_id => get_opt(:nct_id),
      :sponsor_type => get_opt('type'),
      :agency_class => get('agency_class'),
      :agency => get('agency'),
    }
  end

end
