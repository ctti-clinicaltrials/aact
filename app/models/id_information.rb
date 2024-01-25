class IdInformation < StudyRelationship
  self.table_name = 'id_information'
  def self.top_level_label
    '//id_info'
  end

  def self.mapper(json)
    # return unless @protocol_section
    protocol_sdection = json.dig('protocolSection')
    return unless protocol_section

    identification_module = protocol_section.dig('identificationModule')
    return unless identification_module

    nct_id_alias = identification_module.dig('nctIdAliases') || []
    secondary_info = identification_module.dig('secondaryIdInfo', 'id') || []
    org_study_info = identification_module['orgStudyIdInfo']
    collection = []
    collection << {
      nct_id: nct_id,
      id_source: 'org_study_id',
      id_type: identification_module.dig('orgStudyIdInfo', ...), # there is not 'OrgStudyIdType' but 'id' only
      id_type_description: identification_module.dig('orgStudyIdInfo', "link"), # there is no links in 'orgStudyIdInfo' id only, but 'domain' inside 'secondaryIdInfos' 
      id_link: identification_module.dig('orgStudyIdInfo', "OrgStudyIdLink"), # there is no links in 'OrgStudyIdLink 
      id_value: org_study_info['id'] 
      } if org_study_info

    nct_id_alias.each do |nct_alias|
      collection << { 
        nct_id: nct_id, 
        id_source: 'nct_alias', 
        id_type: nil,
        id_type_description: nil,
        id_link: nil,
        id_value: nct_alias
      }
    end
    secondary_info.each do |info|
      collection << { 
        nct_id: nct_id,
        id_source: 'secondary_id',
        id_type: info['SecondaryIdType'],
        id_type_description: info['SecondaryIdDomain'],
        id_link: info['SecondaryIdLink'],
        id_value: info['SecondaryId'],
      }
    end
    collection
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
