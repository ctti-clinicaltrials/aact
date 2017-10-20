class Design < StudyRelationship

  def self.top_level_label
    '//study_design_info'
  end

  def attribs
    @xml=opts[:xml].xpath('//study_design_info')
    {
      :allocation => get('allocation'),
      :observational_model => get('observational_model'),
      :intervention_model => get('intervention_model'),
      :intervention_model_description => get('intervention_model_description'),
      :primary_purpose => get('primary_purpose'),
      :time_perspective => get('time_perspective'),
      :masking => get_masking,
      :masking_description => get('masking_description'),
      :subject_masked => is_masked?(['Subject','Participant']),
      :caregiver_masked => is_masked?(['Caregiver','Care Provider']),
      :investigator_masked => is_masked?(['Investigator']),
      :outcomes_assessor_masked => is_masked?(['Outcomes Assessor']),
    }
  end

  def get_masking
    val = get('masking')
    if val
      res=val.split('(').first.strip
      (res.include? 'None') ? val.strip : res
    end
  end

  def is_masked?(roles)
    roles.each{|role|
      return true if get_masked_roles.try(:include?,role)
    }
    nil
  end

  def get_masked_roles
    val=get('masking')
    result=val.split('(').last if val
    result.tr('()', '') if result
  end

end
