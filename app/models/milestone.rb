class Milestone < StudyRelationship
  belongs_to :group

  def self.create_all_from(opts)
    Milestone.import(self.nested_pop_create(opts.merge(:name=>'milestone')))
  end

  def self.nested_pop_create(opts)
    name=opts[:name]
    all=opts[:xml].xpath("//#{name}_list").xpath(name)
    col=[]
    xml=all.pop
    while xml
      opts[:xml]=xml
      opts[:title]=xml.xpath('title').text
      opts[:period_title]=xml.parent.parent.xpath('title').text
      col << self.pop_create(opts.merge(:name=>'participants'))
      xml=all.pop
    end
    col.flatten
  end

  def attribs
    {
      :ctgov_group_id => get_attribute('group_id'),
      :ctgov_group_enumerator => integer_in(get_attribute('group_id')),
      :participant_count => get_attribute('count').to_i,
      :description => xml.text,
      :title => get_opt('title'),
      :group => get_group,
      :period_title => get_opt(:period_title)
    }
  end

  def get_group
    group_node=xml.attribute('group_id')
    gid=group_node.try(:value)
    opts[:groups].each{|g|
      if g.ctgov_group_enumerator==integer_in(gid)
        return g
      end
    }
  end

end
