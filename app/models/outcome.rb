class Outcome < StudyRelationship
  extend FastCount
	has_many :outcome_groups, inverse_of: :outcome, autosave: true
	has_many :result_groups, :through => :outcome_groups

  def self.create_all_from(opts)
    all=opts[:xml].xpath('//clinical_results').xpath("outcome_list").xpath('outcome')
    outcomes=[]
    xml=all.pop
    while xml
      opts[:xml]=xml
      opts[:result_type]='Outcome'

      opts[:groups]=nil
      opts[:groups]=create_group_set(opts)

      opts[:result_type]='Outcome'
      opts[:type]=xml.xpath('type').text
      opts[:title]=xml.xpath('title').text
      opts[:description]=xml.xpath('description').text
      opts[:time_frame]=xml.xpath('time_frame').text
      opts[:safety_issue]=xml.xpath('safety_issue').text
      opts[:population]=xml.xpath('population').text
      o=new.create_from(opts)
      outcomes << o
      xml=all.pop
    end
    import outcomes.flatten, recursive: true
  end

  def attribs
    {
      :outcome_type   => get_opt('type'),
      :title          => get_opt('title'),
      :description    => get_opt('description'),
      :time_frame     => get_opt('time_frame'),
      :safety_issue   => get_opt('safety_issue'),
      :measure        => get_opt('measure'),
      :population     => get_opt('population'),
      :outcome_groups => OutcomeGroup.create_all_from({:outcome=>self,:groups=>opts[:groups]}),
    }
  end

end

