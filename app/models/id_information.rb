
class IdInformation < StudyRelationship
  self.table_name = 'id_information'
  add_mapping do
    [
      {
        table: :id_information,
        root: [:protocolSection, :identificationModule, :nctIdAliases],
        columns: [
          { name: :id_source, value: 'nct_alias' },
          { name: :id_value, value: nil }
        ]
      },
      {
        table: :id_information,
        root: [:protocolSection, :identificationModule, :orgStudyIdInfo],
        columns: [
          { name: :id_source, value: 'org_study_id' },
          { name: :id_type, value: :type },
          { name: :id_type_description, value: :domain },
          { name: :id_link, value: :link },
          { name: :id_value, value: :id}
        ]
      },
      {
        table: :id_information,
        root: [:protocolSection, :identificationModule, :secondaryIdInfos],
        columns: [
          { name: :id_source, value: 'secondary_id' },
          { name: :id_type, value: :type },
          { name: :id_type_description, value: :domain },
          { name: :id_link, value: :secondaryIdLink },
          { name: :id_value, value: :secondaryId }
        ]
      }
    ]
  end

end

# class IdInformation < StudyRelationship
  # self.table_name = 'id_information'
  # def self.top_level_label
  #   '//id_info'
  # end

  # def self.mapper(json)
  #   return unless json # Correctly handle nil input

  #   protocol_section = json.dig('protocolSection') # Correct the typo here
  #   return unless protocol_section

  #   identification_module = protocol_section.dig('identificationModule')
  #   return unless identification_module

  #   nct_id_alias = identification_module.dig('nctIdAliases') || []
  #   secondary_info = identification_module.dig('secondaryIdInfos', 'id') || []
  #   org_study_info = identification_module['orgStudyIdInfo']
  #   nct_id = protocol_section.dig('identificationModule', 'nctId')
  #   collection = []
  #   collection << {
  #     nct_id: nct_id,
  #     id_source: 'org_study_id',
  #     id_type: identification_module.dig('orgStudyIdInfo', 'type'),
  #     id_type_description: identification_module.dig('orgStudyIdInfo', "domain"),
  #     id_link: identification_module.dig('orgStudyIdInfo', "link"), 
  #     id_value: org_study_info['id'] 
  #     } if org_study_info

  #   nct_id_alias.each do |nct_alias|
  #     collection << { 
  #       nct_id: nct_id, 
  #       id_source: 'nct_alias', 
  #       id_type: nil,
  #       id_type_description: nil,
  #       id_link: nil,
  #       id_value: nct_alias
  #     }
  #   end
  #   secondary_info.each do |info|
  #     collection << { 
  #       nct_id: nct_id,
  #       id_source: 'secondary_id',
  #       id_type: info['secondaryIdType'],
  #       id_type_description: info['domain'],
  #       id_link: info['secondaryIdLink'],
  #       id_value: info['secondaryId'],
  #     }
  #   end
  #   collection
  # end


	# def self.id_types
  #   ['org_study_id','secondary_id','nct_alias']
  # end

  # def self.create_all_from(opts)
  #   col=[]
  #   id_types.collect{|type|
  #     opts[:xml].xpath("//#{type}").collect{|xml|
  #       col << new({:id_type=>type, :id_value=>xml.text.strip, :nct_id=>(opts[:nct_id]) })
  #     }
  #   }
  #   import(col)
  # end
