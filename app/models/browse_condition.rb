class BrowseCondition < StudyRelationship

  def self.create_all_from(options={})
    nct_id=options[:nct_id]
    nodes=options[:xml].xpath("//condition_browse").children
    import(nodes.collect{|node| self.new({:nct_id=>nct_id,:mesh_term=>node.text}) if node.name=='mesh_term'}.compact)
  end

end
