class ResultGroup < StudyRelationship

  has_many :reported_events, autosave: true
  has_many :milestones, autosave: true
  has_many :drop_withdrawals, autosave: true
  has_many :baseline_measures, autosave: true
  has_many :outcome_counts, autosave: true
  has_many :outcome_measurements, autosave: true
  has_many :outcome_analysis_groups, inverse_of: :result_group, autosave: true
  has_many :outcome_analyses, :through => :outcome_analysis_groups

  def self.create_group_set(opts)
    group_xmls=opts[:xml].xpath("group_list").xpath('group')
    groups=[]
    group=group_xmls.pop
    while group
      if !group.blank?
        opts[:group]=group
        groups << create_group_from(opts)
      end
      group=group_xmls.pop
    end
    groups
  end

  def self.create_group_from(opts)
    xml=opts[:group]
    create({
      :nct_id           => opts[:nct_id],
      :ctgov_group_code => xml.attribute('group_id'),
      :result_type      => opts[:result_type],
      :title            => xml.xpath('title').text,
      :description      => xml.xpath('description').text,
    })
  end

end
