class Document < StudyRelationship

  def documents_data
    return unless protocol_section
    nct_id = protocol_section.dig('identificationModule', 'nctId')

    avail_ipds = protocol_section.dig('referencesModule', 'availIpds')
    return unless avail_ipds

    collection = []
    avail_ipds.each do |item|
      collection << {
                      nct_id: nct_id,
                      document_id: item['id'],
                      document_type: item['type'],
                      url: item['url'],
                      comment: item['comment']
                    }
    end
    collection
  end

  add_mapping do
    {
      table: :,
      root: [:, :, :],
      columns: [
        { name: :, value: : },
        { name: :, value: : },
        { name: :, value: : },
        { name: :, value: : },
        { name: :, value: : }
      ]
    }
  end

end
