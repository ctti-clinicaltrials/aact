class Milestone < StudyRelationship
  belongs_to :result_group

  def self.create_all_from(opts)
    opts[:xml]=opts[:xml].xpath('//participant_flow')
    opts[:result_type]='Milestone'
    opts[:groups]=create_group_set(opts)

    import(self.nested_pop_create(opts.merge(:name=>'milestone')))
  end

  def self.nested_pop_create(opts)
    name=opts[:name]
    all=opts[:xml].xpath("//#{name}_list").xpath(name)
    col=[]
    xml=all.pop
    while xml
      opts[:xml]=xml
      opts[:title]=xml.xpath('title').text
      opts[:period]=xml.parent.parent.xpath('title').text
      col << self.pop_create(opts.merge(:name=>'participants'))
      xml=all.pop
    end
    col.flatten
  end

  def attribs
    {
      :result_group => get_group(opts[:groups]),
      :ctgov_group_code => get_attribute('group_id'),
      :participant_count => get_attribute('count').to_i,
      :description => xml.text,
      :title => get_opt('title'),
      :period => get_opt('period')
    }
  end

end
