class Design < StudyRelationship

  def self.top_level_label
    '//study_design_info'
  end

  def attribs
    @xml=opts[:xml].xpath('//study_design_info')
    {
      :description => source,
      :intervention_model => get('intervention_model'),
      :intervention_model_description => get('intervention_model_description'),
      :primary_purpose => get('primary_purpose'),
      :time_perspective => get('time_perspective'),
      :masking => get_masking,
      :masking_description => get('masking_description'),

      :observational_model => get_value_for('Observational Model:'),
      :endpoint_classification => get_value_for('Endpoint Classification:'),
      :allocation => get('allocation'),
      :subject_masked => is_masked?('Subject'),
      :caregiver_masked => is_masked?('Caregiver'),
      :investigator_masked => is_masked?('Investigator'),
      :outcomes_assessor_masked => is_masked?('Outcomes Assessor'),
    }
  end

  def get_masking
    val = get('masking')
    val.split('(').first.strip if val
  end

  def source
    @source ||= get_opt(:xml).xpath("//study_design_info").try(:text)
  end

  def labels
    ['Endpoint Classification:','Observational Model:']
  end

  def is_masked?(role)
    get_masked_roles.try(:include?,role)
  end

  def get_masked_roles
    val=get('masking')
    result=val.split('(').last if val
    result.tr('()', '') if result
  end

  def get_value_for(design_label)
    i=source.index(design_label)  # find label in the string
    return nil if !i  # if not found, return nil
    i=i+design_label.size  # advance past the label to get to the value
    str=source[i..source.size]
    n=0  # will be set to length of value string
    labels.each{|label|  # iterate thru all possible labels.  Find next one
      i=str.index(label)
      if i
        if n==0  # length of value hasn't yet been set.  Set it.
          n=i
        else
          if i < n  # seems we found a label nearer the front of the value.  Use it
            n=i
          end
        end
      end
    }
    if n > 0
      n=n-3
    else
      n=str.size
    end
    str[0..n].strip
  end

end
