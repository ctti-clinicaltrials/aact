class Condition < StudyRelationship

  def self.create_all_from(opts)
    nct_id = opts[:xml].xpath("//nct_id").text
    conditions = opts[:xml].xpath("//condition").collect{|xml|new(:name=>xml.text, :nct_id => nct_id)}.flatten.compact
    import(conditions)
  end

end
