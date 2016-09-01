class Condition < StudyRelationship

  def self.create_all_from(opts)
    conditions = opts[:xml].xpath("//condition").collect{|xml|new(:nct_id=>opts[:nct_id],:name=>xml.text)}.flatten.compact
    import(conditions)
  end

end
