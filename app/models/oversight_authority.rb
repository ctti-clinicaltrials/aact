class OversightAuthority < StudyRelationship

  def self.top_level_label
    '//oversight_info'
  end

  def self.create_all_from(opts)
    nct_id=opts[:nct_id]
    xml=opts[:xml].xpath("//oversight_info").children
    oversight_authorities = (xml.collect {|node|
      self.new({:name=>node.text,:nct_id=>nct_id}) if node.name=='authority'}).compact

    import(oversight_authorities)
  end

end
