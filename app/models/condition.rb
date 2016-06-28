class Condition < StudyRelationship

  def self.create_all_from(opts)
    conditions = opts[:xml].xpath("//condition").collect{|xml|new(:name=>xml.text)}.flatten.compact
    Condition.import(conditions)
  end

end
