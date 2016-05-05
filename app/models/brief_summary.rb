class BriefSummary < StudyRelationship

  def attribs
    {:description=>get_text('brief_summary')}
  end

end
