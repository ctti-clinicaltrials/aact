class ProvidedDocument < ApplicationRecord

  def self.mapper(json)
    return unless json.document_section

    large_docs = json.document_section.dig('largeDocumentModule', 'largeDocs')
    return unless large_docs

    nct_id = json.protocol_section.dig('identificationModule', 'nctId')
    collection = []
    large_docs.each do |doc|
      base_url = 'https://ClinicalTrials.gov/ProvidedDocs/'
      number = "#{nct_id[-2]}#{nct_id[-1]}/#{nct_id}"
      full_url = base_url + number + "/#{doc['filename']}" if doc['filename']

      collection << {
                      nct_id: nct_id,
                      document_type: doc['label'],
                      has_protocol: get_boolean(doc['hasProtocol']),
                      has_icf: get_boolean(doc['hasIcf']),
                      has_sap: get_boolean(doc['hasSap']),
                      document_date: convert_to_date(doc['date']),
                      url: full_url
                    }
    end

    collection
  end

end
