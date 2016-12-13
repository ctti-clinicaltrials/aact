class ParticipantFlow < StudyRelationship

  def participant_flow_tag_exists?
    !opts[:xml].xpath('//participant_flow').blank?
  end

  def attribs
    if participant_flow_tag_exists?
      {
        :recruitment_details=>xml.xpath("//participant_flow").xpath('recruitment_details').try(:text),
        :pre_assignment_details=>xml.xpath("//participant_flow").xpath('pre_assignment_details').try(:text),
      }
    else
      nil
    end
  end

end
