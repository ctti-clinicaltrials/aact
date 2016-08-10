class ResultAgreement < StudyRelationship

  def self.top_level_label
    '//certain_agreements'
  end

  def self.create_all_from(opts)
    objects = super
    ResultAgreement.import(objects)
  end

  def attribs
    {
     :pi_employee => get('pi_employee'),
     :agreement => get('restrictive_agreement'),
    }
  end

end
