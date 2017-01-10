class BaselineCount < StudyRelationship

  belongs_to :result_group

  def self.create_all_from(opts={})
    return [] if opts[:xml].xpath('//baseline').blank?
    original_xml=opts[:xml]
    xml = opts[:xml].xpath('//baseline')
    col=[]
    all=xml.xpath("analyzed_list").xpath('analyzed')
    xml=all.pop
    while xml
      opts[:units]=xml.xpath('units').text
      opts[:scope]=xml.xpath('scope').text
      counts=xml.xpath("count_list").xpath('count')
      c=counts.pop
      while c
        opts[:xml]=c
        col << create_from(opts)
        c=counts.pop
      end
      xml=all.pop
    end
    opts[:xml]=original_xml
    col.flatten.each{|x|x.save!}
  end

  def attribs
    {
      :result_group => get_group(opts[:groups]),
      :ctgov_group_code => get_attribute('group_id'),
      :units => get_opt(:units),
      :scope => get_opt(:scope),
      :count => get_attribute('value'),
    }
  end

end
