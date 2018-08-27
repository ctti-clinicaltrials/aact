class IpdInformationType < StudyRelationship

  def self.create_all_from(opts)
    info_types = opts[:xml].xpath("//ipd_info_type").collect{|xml|new(:nct_id=>opts[:nct_id],:name=>xml.text)}.flatten.compact
    import(info_types)
  end

end
