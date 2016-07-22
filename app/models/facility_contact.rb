class FacilityContact < StudyRelationship
  belongs_to :facility, inverse_of: :facility_contacts, autosave: true

  def attribs
    {
      :name => get_from('contact','last_name'),
      :phone => get_from('contact','phone'),
      :email => get_from('contact','email'),
      :backup_name => get_from('contact_backup','last_name'),
      :backup_phone => get_from('contact_backup','phone'),
      :backup_email => get_from('contact_backup','email')
    }
  end

  def get_from(sublevel,label)
    elem=wrapper1_xml.xpath(sublevel).try(:xpath,label)
    elem.text if elem
  end
end

