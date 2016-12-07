class BaselineGroup < StudyRelationship

  belongs_to :baseline

  def self.create_all_from(opts={})
    xml=opts[:xml].xpath('//baseline')
    opts[:xml]=xml
    col=[]
    all=xml.xpath("group_list").xpath('group')
    xml=all.pop
    while xml
      opts[:xml]=xml
      opts[:title]=xml.xpath('title').text
      opts[:description]=xml.xpath('description').text
      col << create_from(opts)
      xml=all.pop
    end
    col.flatten.each{|x|x.save!}
  end

  def attribs
    {
      #:result_group => get_group(opts[:groups]),
      :ctgov_group_code => get_attribute('group_id'),
      :description => get_opt(:description),
      :title => get_opt(:title),
    }
  end

end
