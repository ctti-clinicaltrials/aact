class DesignOutcome < StudyRelationship
  attr_accessor :type

  def self.create_all_from(options={})
    nct_id=options[:nct_id]
    primary=options[:xml].xpath("//primary_outcome").collect{|xml|
      create_from({:xml=>xml,:type=>'primary',:nct_id=>nct_id})}

    secondary=options[:xml].xpath("//secondary_outcome").collect{|xml|
      create_from({:xml=>xml,:type=>'secondary',:nct_id=>nct_id})}
    import(primary + secondary)
  end

  def attribs
    {
      :measure => get('measure'),
      :title => get('measure'),
      :time_frame => get('time_frame'),
      :safety_issue => get('safety_issue'),
      :description => get('description'),
      :population => get('population'),
      :outcome_type => get_opt(:type)
    }
  end

end
