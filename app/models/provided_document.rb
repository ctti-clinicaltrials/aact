class ProvidedDocument < StudyRelationship

  add_mapping do
    {
      table: :provided_documents,
      root: [:documentSection, :largeDocumentModule, :largeDocs],
      columns: [
        { name: :document_type, value: :label },
        { name: :has_protocol, value: :hasProtocol },
        { name: :has_icf, value: :hasIcf },
        { name: :has_sap, value: :hasSap },
        { name: :document_date, value: :date },
        { name: :url, value: :filename, convert_to: ->(val, nct_id) { "https://ClinicalTrials.gov/ProvidedDocs/#{nct_id[-2..-1]}/#{nct_id}/#{val}" } },
      ]
    }
  end
end
