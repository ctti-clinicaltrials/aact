	class Condition < StudyRelationship

		def self.create_all_from(opts)
			opts[:xml].xpath("//condition").collect{|xml|new(:name=>xml.inner_html)}
		end

	end
