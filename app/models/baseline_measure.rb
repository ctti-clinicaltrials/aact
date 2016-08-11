class BaselineMeasure < StudyRelationship

  belongs_to :result_group

  def self.top_level_label
    '//baseline'
  end

  def self.create_all_from(opts={})
    xml=opts[:xml].xpath('//baseline')
    opts[:xml]=xml
    opts[:result_type]='Baseline Measure'
    opts[:groups]=create_group_set(opts)

    opts[:population]=xml.xpath("population").inner_html
    all=xml.xpath("measure_list").xpath('measure')
    col=[]
    xml=all.pop
    while xml
      opts[:description]=xml.xpath('description').text
      opts[:title]=xml.xpath('title').text
      opts[:units]=xml.xpath('units').text
      opts[:param]=xml.xpath('param').text
      opts[:dispersion]=xml.xpath('dispersion').text
      opts[:name]='category'
      opts[:xml]=xml
      col << self.nested_pop_create(opts)
      xml=all.pop
    end
    col.flatten.each{|x|x.save!}
  end

  def self.nested_pop_create(opts)
    name=opts[:name]
    all=opts[:xml].xpath("#{name}_list").xpath(name)
    col=[]
    xml=all.pop
    while xml
      opts[:category]=xml.xpath('sub_title').text
      opts[:xml]=xml
      opts[:name]='measurement'
      col << pop_create(opts)
      xml=all.pop
    end
    col
  end

  def attribs
    {
      :result_group => get_group(opts[:groups]),
      :ctgov_group_code => gid,
      :population => get_opt(:population),
      :param_type => get_opt(:param),
      :param_value => get_attribute('value'),
      :dispersion_type => get_opt(:dispersion),
      :dispersion_value => get_attribute('spread'),
      :dispersion_lower_limit => get_attribute('lower_limit'),
      :dispersion_upper_limit => get_attribute('upper_limit'),
      :explanation_of_na => xml.text,
      :category => get_opt(:category),
      :title => get_opt(:title),
      :description => get_opt(:description),
      :units => get_opt(:units),
    }
  end

end
