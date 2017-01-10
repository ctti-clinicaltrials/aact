class DropWithdrawal < StudyRelationship
  belongs_to :result_group

  def self.create_all_from(opts)
    import(self.nested_pop_create(opts.merge(:name=>'drop_withdraw_reason')))
  end

  def self.nested_pop_create(opts)
    name=opts[:name]
    all=opts[:xml].xpath("//#{name}_list").xpath(name)
    col=[]
    xml=all.pop
    while xml
      opts[:reason]=xml.xpath('title').text
      opts[:period]=xml.parent.parent.xpath('title').text
      groups=xml.xpath("participants_list").xpath('participants')
      group=groups.pop
      while group
        col << create_from(opts.merge(:xml=>group))
        group=groups.pop
      end
      xml=all.pop
    end
    col.flatten
  end

  def attribs
    {
      :result_group => get_group(opts[:groups]),
      :ctgov_group_code => gid,
      :count => get_attribute('count').to_i,
      :reason => get_opt(:reason),
      :period => get_opt(:period),
    }
  end

end
