class Baseline < StudyRelationship

  has_many :baseline_groups
  has_many :baseline_measures
  has_many :baseline_analyses

  #  Not entirely clear, but appears that as of 12/2/16, there is one baseline per study.  Going with that assumptionased on query against 231,000 study xmls:
  #  SELECT nct_id, count(*) as cnt FROM study_xml_records WHERE XMLEXISTS('//baseline' PASSING BY REF content) group by nct_id order by cnt desc;    Found only one for every study

  def self.top_level_label
    '//baseline'
  end

  def groups
    baseline_groups
  end

  def analyses
    baseline_analyses
  end

  def measures
    baseline_measures
  end

  def baseline_tag_exists?
    !opts[:xml].xpath('//baseline').blank?
  end

  def attribs
    if baseline_tag_exists?
      opts[:xml]=opts[:xml].xpath('//baseline')
      opts[:result_type]='Baseline'
      opts[:groups]=ResultGroup.create_group_set(opts)
      {
       :population =>opts[:xml].xpath('population').try(:text),
       :baseline_groups    => BaselineGroup.create_all_from(opts.merge(:baseline=>self)),
       :baseline_measures  => BaselineMeasure.create_all_from(opts.merge(:baseline=>self)),
       :baseline_analyses  => BaselineAnalysis.create_all_from(opts.merge(:baseline=>self)),
      }
    else
      nil
    end
  end

end
