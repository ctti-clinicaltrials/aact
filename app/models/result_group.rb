class ResultGroup < StudyRelationship
  attr_accessor :baseline_measures

  has_many :baseline_measures
  has_many :outcomes
  has_many :outcome_measures
  has_many :outcome_analyses
  has_many :reported_events
  has_many :milestones
  has_many :drop_withdrawals

  def self.create_group_set(xml)
    group_xmls=xml.xpath("group_list").xpath('group')
    groups=[]
    xml=group_xmls.pop
    while xml
      groups << create_group_from(xml)
      xml=group_xmls.pop
    end
    groups
  end

  def self.create_group_from(xml)
    g=new({:ctgov_group_code => xml.attribute('group_id'),
           :title => xml.xpath('title').text,
           :description=>xml.xpath('description').text
          })
    g.save!
    g
  end

  def self.create_all_from(opts)
    opts[:xml]=opts[:xml].xpath('//participant_flow')
    groups=pop_create(opts.merge(:name=>'group'))
    opts[:xml]=opts[:xml].xpath('//outcome_list')
    additional_groups=pop_create(opts.merge(:name=>'group'))
    opts[:groups]=groups
    groups

    import(groups)
  end

  def attribs
    {
      :ctgov_group_code => get_attribute('group_id'),
      :description => get('description'),
      :title => get('title'),
      :participant_count => get_attribute('count').to_i,
    }
  end

  def baseline_measures
    @baseline_measures ||=BaselineMeasure.where("nct_id=? and ctgov_group_enumerator=?",nct_id,ctgov_group_enumerator)
  end

  def set_participant_count
    self.save!
  end

  def calc_participant_count
    # best guess for this group - based on outcome_measure: 'Number of Participants'
    study.outcome_measures.where(title: 'Number of Participants').pluck('measure_value').map { |val| val.to_i }.max
  end

end
