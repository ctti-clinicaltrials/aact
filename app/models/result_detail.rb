	class ResultDetail < StudyRelationship

		def attribs
			{
			 :recruitment_details => xml.xpath('//clinical_results').xpath('participant_flow').xpath('recruitment_details').children.text,
			 :pre_assignment_details => xml.xpath('//clinical_results').xpath('participant_flow').xpath('pre_assignment_details').children.text,
			}
		end

	end
