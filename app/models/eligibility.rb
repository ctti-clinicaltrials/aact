class Eligibility < StudyRelationship

  def attribs
    {
      :sampling_method=>get('sampling_method'),
      :population=>get_text('study_pop').strip,
      :maximum_age=>get('maximum_age'),
      :minimum_age=>get('minimum_age'),
      :gender=>get('gender'),
      :healthy_volunteers=>get('healthy_volunteers'),
      :criteria=>get_text('criteria')
    }
  end

  def get(label)
    #  override the superclass to search for label from the top of the doc
    xml.xpath("//#{label}").text
  end

end
