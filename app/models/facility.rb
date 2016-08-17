class Facility < StudyRelationship

  has_many :facility_contacts, autosave: true
  has_many :facility_investigators, autosave: true

  def self.create_all_from(opts)
    col=[]
    opts[:xml].xpath("//location").collect{|location|
      opts[:location]=location
      opts[:status]=location.xpath('status').text

      location.xpath("facility").collect{|xml|
        opts[:xml]=xml
        col << new.create_from(opts)
      }
    }
    import col, recursive: true
  end

  def attribs
    {
      :name    => get('name'),
      :city    => get_addr('city'),
      :state   => get_addr('state'),
      :zip     => get_addr('zip'),
      :country => get_addr('country'),
      :status  => get_opt('status'),
      :facility_contacts => FacilityContact.create_all_from(opts.merge(:facility=>self)),
      :facility_investigators => FacilityInvestigator.create_all_from(opts.merge(:facility=>self)),
    }
  end

  def get_addr(label)
    xml.xpath('address').try(:xpath,label).try(:text)
  end

end
