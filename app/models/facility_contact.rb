class FacilityContact < StudyRelationship
  belongs_to :facility, autosave: true

  def self.create_all_from(opts)
    contacts(opts) + backup_contacts(opts)
  end

  def self.contacts(opts)
    opts[:location].xpath('contact').collect{|xml|
      new.create_from({:xml=>xml,:nct_id=>opts[:nct_id], :contact_type=>'primary'})
    }
  end

  def self.backup_contacts(opts)
    opts[:location].xpath('contact_backup').collect{|xml|
      new.create_from({:xml=>xml,:nct_id=>opts[:nct_id], :contact_type=>'backup'})}
  end

  def attribs
    {
      :nct_id => get_opt('nct_id'),
      :contact_type => get_opt('contact_type'),
      :name => get('last_name'),
      :phone => get_phone,
      :email => get('email'),
      :facility => get_opt('facility'),
    }
  end

end
