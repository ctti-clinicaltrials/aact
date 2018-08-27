class IpdInformationType < StudyRelationship

  def self.create_all_from(opts)
    col=[]
    opts[:xml].xpath("//ipd_info_type").collect{|xml|
      col << new({:name=>xml.text.strip, :nct_id=>(opts[:nct_id]) })
    }
    import(col)
  end

end
