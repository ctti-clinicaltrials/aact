class IdInformation < StudyRelationship
  self.table_name = 'id_information'
  def self.top_level_label
    '//id_info'
  end

	def self.id_types
    ['org_study_id','secondary_id','nct_alias']
  end

  def self.create_all_from(opts)
    col=[]
    id_types.collect{|type|
      opts[:xml].xpath("//#{type}").collect{|xml|
        col << new({:id_type=>type, :id_value=>xml.text.strip, :nct_id=>(opts[:nct_id]) })
      }
    }
    import(col)
  end

end
