class Outcome < StudyRelationship
  extend FastCount
  belongs_to :result_group, autosave: true

  has_many :outcome_groups, inverse_of: :outcome, autosave: true
  has_many :outcome_analyses, inverse_of: :outcome, autosave: true
  has_many :outcome_measured_values

  accepts_nested_attributes_for :outcome_groups

  def self.create_all_from(opts)
    all=opts[:xml].xpath('//clinical_results').xpath("outcome_list").xpath('outcome')
    col=[]
    outcome_groups=[]
    outcomes=[]
    xml=all.pop
    while xml
      opts[:xml]=xml
      opts[:result_type]='Outcome'
      opts[:groups]=create_group_set(opts)
      opts[:type]=xml.xpath('type').text
      opts[:title]=xml.xpath('title').text
      opts[:description]=xml.xpath('description').text
      opts[:time_frame]=xml.xpath('time_frame').text
      opts[:safety_issue]=xml.xpath('safety_issue').text
      opts[:population]=xml.xpath('population').text
      opts[:xml]=xml
      outcome=new({
        :nct_id       => opts[:nct_id],
        :outcome_type => opts[:type],
        :title        => opts[:title],
        :description  => opts[:description],
        :time_frame   => opts[:time_frame],
        :safety_issue => opts[:safety_issue],
        :measure      => opts[:measure],
        :population   => opts[:population],
      })
      grps=get_outcome_groups(opts.merge(:outcome=>outcome))
			puts "grps size is #{grps.size}"
      outcomes << outcome
      xml=all.pop
    end
    import(outcomes.flatten)
  end

  def self.get_outcome_groups(opts)
    #opts[:outer_xml]=opts[:xml]
    all=opts[:xml].xpath("group_list").xpath('group')
    col=[]
    xml=all.pop
    while xml
      opts[:xml]=xml
      og = OutcomeGroup.create_from(opts)
			col << og
			opts[:outcome].outcome_groups << og
			puts "Number of groups for outcome #{opts[:outcome].outcome_groups.size}"
      xml=all.pop
    end
    col
  end

end
