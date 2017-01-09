class Outcome < StudyRelationship
  has_many :outcome_groups, inverse_of: :outcome, autosave: true
  has_many :outcome_counts, inverse_of: :outcome, autosave: true
  has_many :outcome_analyses, inverse_of: :outcome, autosave: true
  has_many :outcome_measurements, inverse_of: :outcome, autosave: true

  def groups
    outcome_groups
  end

  def analyses
    outcome_analyses
  end

  def self.create_all_from(opts)
    all=opts[:xml].xpath('//clinical_results').xpath("outcome_list").xpath('outcome')
    outcomes=[]
    xml=all.pop
    while xml
      opts[:outcome_xml]=xml
      opts[:xml]=xml
      opts[:result_type]='Outcome'
      opts[:groups]=create_group_set(opts)
      opts[:type]=xml.xpath('type').text
      opts[:title]=xml.xpath('title').text
      opts[:description]=xml.xpath('description').text
      opts[:time_frame]=xml.xpath('time_frame').text
      opts[:safety_issue]=xml.xpath('safety_issue').text
      opts[:population]=xml.xpath('population').text
      opts[:posting_date]=xml.xpath('posting_date').text

      opts[:xml]=xml.xpath('measure')
      opts[:units]=opts[:xml].xpath('units').text
      opts[:units_analyzed]=opts[:xml].xpath('units_analyzed').text
      opts[:param_type]=opts[:xml].xpath('param').text
      opts[:dispersion_type]=opts[:xml].xpath('dispersion').text

      o=new.create_from(opts)
      o.outcome_counts       = OutcomeCount.create_all_from(opts.merge(:outcome=>o))
      o.outcome_measurements = OutcomeMeasurement.create_all_from(opts.merge(:outcome=>o))
      outcomes << o
      xml=all.pop
    end
    import outcomes.flatten, recursive: true
  end

  def attribs
    {
      :outcome_type    => get_opt('type'),
      :title           => get_opt('title'),
      :description     => get_opt('description'),
      :time_frame      => get_opt('time_frame'),
      :safety_issue    => get_opt('safety_issue'),
      :population      => get_opt('population'),
      :units           => get_opt('units'),
      :units_analyzed  => get_opt('units_analyzed'),
      :param_type      => get_opt('param_type'),
      :dispersion_type => get_opt('dispersion_type'),
      :anticipated_posting_month_year  => get_opt('posting_date'),
      :outcome_groups   => OutcomeGroup.create_all_from({:nct_id=>opts[:nct_id],:outcome=>self,:groups=>opts[:groups]}),
      :outcome_analyses => OutcomeAnalysis.create_all_from(opts.merge(:outcome=>self)),
    }
  end

end
