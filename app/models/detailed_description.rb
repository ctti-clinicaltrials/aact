class DetailedDescription < StudyRelationship

  def attribs
    {:description=>get_text('detailed_description')}
  end

end
