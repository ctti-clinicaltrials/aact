class ProvidedDocument < ApplicationRecord

  def self.create_all_from(opts)
    docs=opts[:xml].xpath('//provided_document_section')
    return nil if docs.blank?
    opts[:docs]=docs.children
    collect_docs(opts)
  end

  def self.collect_docs(opts)
    opts[:docs].each{|doc|
      type=doc.xpath('document_type').text
      type=nil if type.blank?
      case doc.xpath('document_has_protocol').text.try(:downcase)
      when 'yes'
        has_protocol=true
      when 'no'
        has_protocol=false
      else
        has_protocol=nil
      end

      case doc.xpath('document_has_icf').text.try(:downcase)
      when 'yes'
        has_icf=true
      when 'no'
        has_icf=false
      else
        has_icf=nil
      end

      case doc.xpath('document_has_sap').text.try(:downcase)
      when 'yes'
        has_sap=true
      when 'no'
        has_sap=false
      else
        has_sap=nil
      end

      url=doc.xpath('document_url').text
      url=nil          if url.blank?
      document_date=doc.xpath('document_date').text
      if !type.blank?
        create({
          :nct_id => opts[:nct_id],
          :document_type => type,
          :document_date => document_date,
          :has_protocol  => has_protocol,
          :has_icf       => has_icf,
          :has_sap       => has_sap,
          :url           => url,
        })
      end
    }
  end

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
                      document_date: get_date(doc['date']),
                      url: full_url
                    }

    end
    
    collection
  end

end
