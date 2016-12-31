class OutcomeMeasure < StudyRelationship
  belongs_to :outcome, autosave: true
  has_many :outcome_counts, autosave: true
  has_many :outcome_measurements, autosave: true

  def counts
    outcome_counts
  end

  def measurements
    outcome_measurements
  end

  def self.create_all_from(opts)
    all=opts[:outcome_xml].xpath("measure")
    all=opts[:outcome_xml].xpath("measure_list").xpath("measure") if all.blank?

    col=[]
    xml=all.pop
    while xml
      opts[:xml]=xml
      opts[:measure_title]=xml.xpath('title').text
      opts[:measure_description]=xml.xpath('description').text
      opts[:population]=xml.xpath('population').text
      opts[:measure_units]=xml.xpath('units').text
      opts[:units_analyzed]=xml.xpath('units_analyzed').text
      opts[:dispersion_type]=xml.xpath('dispersion').text
      opts[:param_type]=xml.xpath('param').text
      om=new.create_from(opts)
      om.outcome_counts       = OutcomeCount.create_all_from(opts.merge(:outcome_measure=>om))
      om.outcome_measurements = OutcomeMeasurement.create_all_from(opts.merge(:outcome_measure=>om))
      col << om
      xml=all.pop
    end
    col
  end

  def attribs
    {
      :title                  => get_opt('measure_title'),
      :description            => get_opt('measure_description'),
      :population             => get_opt('population'),
      :units                  => get_opt('measure_units'),
      :units_analyzed         => get_opt('units_analyzed'),
      :dispersion_type        => get_opt('dispersion_type'),
      :param_type             => get_opt('param_type'),
      :outcome                => get_opt('outcome'),
    }
  end

end
