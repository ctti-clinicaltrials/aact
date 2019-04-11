class OutcomeCount < StudyRelationship
  belongs_to :outcome, autosave: true
  belongs_to :result_group, autosave: true

  def self.create_all_from(opts)
    all_analyzed=opts[:xml].xpath("analyzed_list").xpath('analyzed')
    col=[]
    a=all_analyzed.pop
    return col if a.blank?
    while a
      opts[:scope]=a.xpath('scope').text
      opts[:units]=a.xpath('units').text
      all_counts=a.xpath("count_list").xpath('count')
      cnt=all_counts.pop
      return col if cnt.blank?
      while cnt
        opts[:xml]=cnt
        col << new.create_from(opts)
        cnt=all_counts.pop
      end
      a=all_analyzed.pop
    end
    col.flatten
  end

  def attribs
    {
     :result_group => get_group(opts[:groups]),
     :outcome => get_opt(:outcome),
     :ctgov_group_code => get_attribute('group_id'),
     :scope => get_opt(:scope),
     :units => get_opt(:units),
     :count => get_attribute('value'),
    }
  end

end
