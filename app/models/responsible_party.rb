	class ResponsibleParty < StudyRelationship

		def self.top_level_label
			'//responsible_party'
		end

		def attribs
			{
				:responsible_party_type => get('responsible_party_type'),
				:affiliation => get('investigator_affiliation'),
				:name => get('investigator_full_name'),
				:title => get('investigator_title'),
			}
		end

		def label
			"#{try(:name)} #{try(:title)}"
		end

	end
