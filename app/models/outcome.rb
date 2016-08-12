class Outcome < StudyRelationship
  extend FastCount
  belongs_to :result_group, autosave: true

  def self.create_all_from(opts)
    all=opts[:xml].xpath('//clinical_results').xpath("outcome_list").xpath('outcome')
    col=[]
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
      outcomes << outcome
      xml=all.pop
    end
    import(outcomes.flatten)
  end

end
