class BriefSummary < StudyRelationship

  def attribs
    val=get_text('brief_summary')
    if val.blank?
      nil
    else
      {:description=>val}
    end
  end

end
