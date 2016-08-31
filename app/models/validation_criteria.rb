class ValidationCriteria

  def self.for(nct_id)
    send(nct_id.to_sym)
  end

  def self.study_ids
    methods.select{|m|m.to_s.size==11 and m.to_s.starts_with?('NCT')}
  end

  def self.NCT00734539
    {
    'Org Study ID': ["study.id_information.select{|x|x.id_type=='org_study_id'}.first.id_value", 'Pro00001538'],
    'ID Info Count': ['study.id_information.size', 3],
    'ID Info has NCT_ID': ['study.id_information.first.nct_id', 'NCT00734539'],
    }
  end

  def self.NCT01841593
    {
    'Outcome Count': ['study.outcomes.size', 5],
    }
  end

  def self.NCT01076361
    { 'NCT ID'=> ['nct_id','NCT01076361'] }
  end

end
