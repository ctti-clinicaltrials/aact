	class Keyword < StudyRelationship

		def self.top_level_label
			'//keyword'
		end

		def attribs
			{:name => opts[:xml].inner_html}
		end

	end
