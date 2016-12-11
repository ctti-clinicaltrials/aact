class DetailedDescription < StudyRelationship

  def attribs
    val=get_text('detailed_description')
    if val.blank?
      nil
    else
      {:description=>val}
    end
  end

end
