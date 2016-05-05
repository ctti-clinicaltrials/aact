	class SecondaryId < StudyRelationship

		def self.top_level_label
			'//secondary_id'
		end

		def attribs
			{:secondary_id=>xml.inner_html}
		end

	end
