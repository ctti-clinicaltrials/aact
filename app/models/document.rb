class Document < StudyRelationship

  def self.create_all_from(opts)
    docs=opts[:xml].xpath('//study_docs')
    return nil if docs.blank?
    opts[:docs]=docs.children
    collect_docs(opts)
  end

  def self.collect_docs(opts)
    opts[:docs].each{|doc|
      type=doc.xpath('doc_type').text
      url=doc.xpath('doc_url').text
      if !type.blank?
        create({
          :nct_id => opts[:nct_id],
          :document_type => type,
          :document_url => url,
        })
      end
    }
  end

end
