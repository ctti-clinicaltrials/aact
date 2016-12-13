class BaselineGroup < StudyRelationship

  belongs_to :baseline
  belongs_to :result_group

  def self.create_all_from(opts={})
    original_xml=opts[:xml]
    xml=opts[:xml]
    col=[]
    all_leaves=opts[:xml].xpath("group_list").xpath('group')
    leaf=all_leaves.pop
    while leaf
      opts[:xml]=leaf   # argh.  this needs refactoring.  Have to do this for the get_group to work
      opts[:ctgov_group_code]=leaf.get_attribute('group_id')
      opts[:title]=leaf.xpath('title').text
      opts[:description]=leaf.xpath('description').text
      col << create_from(opts)
      leaf=all_leaves.pop
    end
    opts[:xml]=original_xml
    col.flatten.each{|x|x.save!}
  end

  def attribs
    {
      :result_group => get_group(opts[:groups]),
      :ctgov_group_code => get_attribute('group_id'),
      :description => get_opt(:description),
      :title => get_opt(:title),
    }
  end

end
