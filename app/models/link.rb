class Link < StudyRelationship

  # def links_data
  #   return unless protocol_section

  #   nct_id = protocol_section.dig('identificationModule', 'nctId')
  #   see_also_links = protocol_section.dig('referencesModule', 'seeAlsoLinks')
  #   return unless see_also_links

  #   collection = []
  #   see_also_links.each do |link|
  #     collection << { nct_id: nct_id, url: link['url'], description: link['label'] }
  #   end
    
  #   collection
  # end

  add_mapping do
    {
      table: ,
      root: [],
      columns: [
        { name: , value:  },
        { name: , value:  }
      ]
    }
  end

end
