class BaselineMeasure < StudyRelationship
  def self.create_all_from(opts={})
    all=opts[:xml].xpath('//baseline').xpath("measure_list").xpath('measure')
    col=[]
    xml=all.pop
    while xml
      opts[:description]=xml.xpath('description').inner_html
      opts[:title]=xml.xpath('title').inner_html
      opts[:units]=xml.xpath('units').inner_html
      opts[:param]=xml.xpath('param').inner_html
      opts[:dispersion]=xml.xpath('dispersion').inner_html
      opts[:name]='category'
      opts[:xml]=xml
      col << self.nested_pop_create(opts)
      xml=all.pop
    end

    BaselineMeasure.import(col.flatten)
  end

  def self.nested_pop_create(opts)
    name=opts[:name]
    all=opts[:xml].xpath("#{name}_list").xpath(name)
    col=[]
    xml=all.pop
    while xml
      opts[:category]=xml.xpath('sub_title').inner_html
      opts[:xml]=xml
      opts[:name]='measurement'
      col << pop_create(opts)
      xml=all.pop
    end
    col.flatten
  end

  def attribs
    {
      :ctgov_group_id => get_attribute('group_id'),
      :ctgov_group_enumerator => integer_in(get_attribute('group_id')),
      :measure_value => get_attribute('value'),
      :lower_limit => get_attribute('lower_limit'),
      :upper_limit => get_attribute('upper_limit'),
      :spread => get_attribute('spread'),
      :measure_description => xml.inner_html,
      :category => get_opt(:category),
      :title => get_opt(:title),
      :description => get_opt(:description),
      :units => get_opt(:units),
      :param => get_opt(:param),
      :dispersion => get_opt(:dispersion),
    }
  end

end
