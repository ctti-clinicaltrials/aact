	class Link < StudyRelationship

		def self.top_level_label
			'//link'
		end

		def attribs
			{:url=>get('url'),
			 :description => get('description')}
		end

	end
