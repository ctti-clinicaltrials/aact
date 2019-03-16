class ProvidedDocument < StudyRelationship

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

end
