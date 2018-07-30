class Document < StudyRelationship

  def self.create_all_from(opts)
    docs=opts[:xml].xpath('//study_docs')
    return nil if docs.blank?
    opts[:docs]=docs.children
    collect_docs(opts)
  end

  def self.collect_docs(opts)
    opts[:docs].each{|doc|
      id=doc.xpath('doc_id').text
      type=doc.xpath('doc_type').text
      url=doc.xpath('doc_url').text
      comment=doc.xpath('doc_comment').text
      id=nil if id.blank?
      type=nil if type.blank?
      url=nil if url.blank?
      comment=nil if comment.blank?
      if !type.blank?
        create({
          :nct_id => opts[:nct_id],
          :document_id   => id,
          :document_type => type,
          :url           => url,
          :comment       => comment,
        })
      end
    }
  end

end
