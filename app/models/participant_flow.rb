	class ParticipantFlow < StudyRelationship

		def attribs
      {
			 :recruitment_details=>xml.xpath("//participant_flow").xpath('recruitment_details').try(:inner_html),
       :pre_assignment_details=>xml.xpath("//participant_flow").xpath('pre_assignment_details').try(:inner_html),
			}
		end

	end
