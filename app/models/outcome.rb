class Outcome < StudyRelationship
  extend FastCount

  attr_accessor :milestones, :drop_withdrawals

  belongs_to :group
  has_many :outcome_measures, inverse_of: :outcome, autosave: true
  has_many :outcome_analyses, inverse_of: :outcome, autosave: true

  def self.create_all_from(opts)
    all=opts[:xml].xpath('//clinical_results').xpath("outcome_list").xpath('outcome')
    col=[]
    xml=all.pop
    while xml
      opts[:type]=xml.xpath('type').text
      opts[:title]=xml.xpath('title').text
      opts[:description]=xml.xpath('description').text
      opts[:time_frame]=xml.xpath('time_frame').text
      opts[:safety_issue]=xml.xpath('safety_issue').text
      opts[:population]=xml.xpath('population').text
      opts[:xml]=xml
      col << nested_pop_create(opts.merge(:name=>'group'))
      xml=all.pop
    end
    outcomes = col.flatten

    Outcome.import(outcomes, recursive: true)
  end

  def self.nested_pop_create(opts)
    name=opts[:name]
    opts[:outer_xml]=opts[:xml]
    all=opts[:xml].xpath("#{name}_list").xpath(name)
    col=[]
    xml=all.pop
    if xml.blank?
      outcome = create_from(opts)
      outcome_measures = OutcomeMeasure.create_all_from(opts.merge(:outcome=>outcome,:xml=>opts[:outer_xml],:group_id_of_interest=>outcome.gid)).compact
      outcome_analyses = OutcomeAnalysis.create_all_from(opts.merge(:outcome=>outcome,:xml=>opts[:outer_xml],:group_id_of_interest=>outcome.gid)).compact
      outcome_measures.each do |outcome_measure|
        outcome.outcome_measures.build(outcome_measure)
      end

      outcome_analyses.each do |outcome_analysis|
        outcome.outcome_analyses.build(outcome_analysis)
      end
      col << outcome
    else
      while xml
        opts[:xml]=xml
        outcome = create_from(opts)
        outcome_measures = OutcomeMeasure.create_all_from(opts.merge(:outcome=>outcome,:xml=>opts[:outer_xml],:group_id_of_interest=>outcome.gid)).compact
        outcome_analyses = OutcomeAnalysis.create_all_from(opts.merge(:outcome=>outcome,:xml=>opts[:outer_xml],:group_id_of_interest=>outcome.gid)).compact
        outcome_measures.each do |outcome_measure|
          outcome.outcome_measures.build(outcome_measure)
        end
        outcome_analyses.each do |outcome_analysis|
          outcome.outcome_analyses.build(outcome_analysis)
        end
        col << outcome
        xml=all.pop
      end
    end
    col.flatten
  end

  def attribs
    {
      :ctgov_group_id => get_attribute('group_id'),
      :ctgov_group_enumerator => integer_in(get_attribute('group_id')),
      :group_description => get('description'),
      :group_title => get('title'),
      :participant_count => get_attribute('count').to_i,
      :outcome_type => get_opt(:type),
      :group        => get_group,
      :title        => get_opt(:title),
      :time_frame   => get_opt(:time_frame),
      :safety_issue => get_opt(:safety_issue),
      :population   => get_opt(:population),
      :description  => get_opt(:description),
      # :outcome_analyses => OutcomeAnalysis.create_all_from(opts.merge(:outcome=>self,:xml=>opts[:outer_xml],:group_id_of_interest=>gid)).compact,
      # :outcome_measures => OutcomeMeasure.create_all_from(opts.merge(:outcome=>self,:xml=>opts[:outer_xml],:group_id_of_interest=>gid)).compact,
    }
  end

  def gid
    opts[:xml].attribute('group_id').try(:value)
  end

  def get_group
    opts[:groups].each{|g| return g if g.ctgov_group_enumerator==integer_in(gid)}
    # found case where groups were not defined in participant_flow tag,
    # but referenced in outcomes.  In that case, create a group for this outcome.
    # But if this outcome doesn't define any groups (gid is nil), then just
    # link the outcome to the study and not to any groups.
    if !gid.nil?
      new_group=Group.create_from(opts)
      opts[:groups] << new_group
      return new_group
    end
  end

  def measures
    outcome_measures
  end

  def analyses
    outcome_analyses
  end

  def type
    outcome_type
  end

end
