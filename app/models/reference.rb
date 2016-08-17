class Reference < StudyRelationship
  self.table_name='study_references'

  def self.nodes(opts)
    opts[:xml].xpath('//reference') + opts[:xml].xpath('//results_reference')
  end

  def self.create_all_from(opts)
    col=[]
    nodes(opts).each{|xml|
      opts[:xml]=xml
      col << create_from(opts)
    }
    import(col.compact)
  end

  def attribs
    { :citation => get('citation'),
      :pmid => get('PMID'),
      :reference_type => get_opt('xml').name,
    }
  end

  def type
    reference_type
  end

end
