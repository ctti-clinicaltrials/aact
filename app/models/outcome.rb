class Outcome < StudyRelationship
  has_many :outcome_counts, inverse_of: :outcome, autosave: true
  has_many :outcome_analyses, inverse_of: :outcome, autosave: true
  has_many :outcome_measurements, inverse_of: :outcome, autosave: true

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
      g=create_group_set(opts)
      opts[:groups]=g
      opts[:type]=xml.xpath('type').text
      opts[:title]=xml.xpath('title').text
      opts[:description]=xml.xpath('description').text
      opts[:time_frame]=xml.xpath('time_frame').text
      opts[:population]=xml.xpath('population').text
      opts[:posting_date]=xml.xpath('posting_date').text

      opts[:xml]=xml.xpath('measure')
      opts[:units]=opts[:xml].xpath('units').text
      opts[:units_analyzed]=opts[:xml].xpath('units_analyzed').text
      opts[:param_type]=opts[:xml].xpath('param').text
      opts[:dispersion_type]=opts[:xml].xpath('dispersion').text

      o=new.create_from(opts)
      o.outcome_counts       = OutcomeCount.create_all_from(opts.merge(:outcome=>o,:groups=>g))
      o.outcome_measurements = OutcomeMeasurement.create_all_from(opts.merge(:outcome=>o,:groups=>g))
      o.outcome_analyses     = OutcomeAnalysis.create_all_from(opts.merge(:outcome=>o,:groups=>g))
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
      :population      => get_opt('population'),
      :units           => get_opt('units'),
      :units_analyzed  => get_opt('units_analyzed'),
      :param_type      => get_opt('param_type'),
      :dispersion_type => get_opt('dispersion_type'),
      :anticipated_posting_month_year  => get_opt('posting_date'),
      :anticipated_posting_date  => convert_date('posting_date'),
    }
  end

  def convert_date(label)
    dt=get_opt(label)
    return nil if dt.blank?
    begin
      return dt.to_date.end_of_month  if (dt.count '/') == 1
      return dt.to_date
    rescue
      # return nil if invalid date
      nil
    end
  end

end
