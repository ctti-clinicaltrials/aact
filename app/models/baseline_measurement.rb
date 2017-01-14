class BaselineMeasurement < StudyRelationship

  belongs_to :result_group

  def self.create_all_from(opts={})

    return [] if opts[:xml].xpath('//baseline').blank?
    original_xml=opts[:xml]
    opts[:xml]=opts[:xml].xpath('//baseline')
    opts[:result_type]='Baseline'
    opts[:groups]=ResultGroup.create_group_set(opts)
    col=[]
    all=opts[:xml].xpath("measure_list").xpath('measure')
    measure=all.pop
    while measure
      opts[:description]=measure.xpath('description').text
      opts[:title]=measure.xpath('title').text
      opts[:units]=measure.xpath('units').text
      opts[:param]=measure.xpath('param').text
      opts[:dispersion]=measure.xpath('dispersion').text
      classifications=measure.xpath("class_list").xpath('class')
      a_class=classifications.pop
      while a_class
        opts[:classification]=a_class.xpath('title').text
        opts[:class]=a_class
        col << self.nested_pop_create(opts)
        a_class=classifications.pop
      end
      measure=all.pop
    end
    opts[:xml]=original_xml
    BaselineCount.create_all_from(opts)
    col.flatten.each{|x|x.save!}
  end

  def self.nested_pop_create(opts)
    all=opts[:class].xpath("category_list").xpath('category')
    col=[]
    cat=all.pop
    while cat
      opts[:category]=cat.xpath('title').text
      opts[:xml]=cat
      measurements=cat.xpath("measurement_list").xpath('measurement')
      measurement=measurements.pop
      while measurement
        opts[:xml]=measurement
        opts[:param_value]=measurement.attribute('value').try(:value)
        if opts[:param_value] == 'NA'
          opts[:param_value_num]=nil
        else
          opts[:param_value_num]=opts[:param_value]
        end
        opts[:dispersion_value]=measurement.attribute('spread').try(:value)
        if opts[:dispersion_value] == 'NA'
          opts[:dispersion_value_num]=''
        else
          opts[:dispersion_value_num]=opts[:dispersion_value]
        end
        opts[:lower_limit]=measurement.attribute('lower_limit').try(:value)
        opts[:upper_limit]=measurement.attribute('upper_limit').try(:value)

        col << create_from(opts)
        measurement=measurements.pop
      end
      cat=all.pop
    end
    col
  end

  def attribs
    {
      :result_group           => get_group(opts[:groups]),
      :classification         => get_opt('classification'),
      :category               => get_opt(:category),
      :ctgov_group_code       => gid,
      :title                  => get_opt(:title),
      :description            => get_opt(:description),
      :units                  => get_opt(:units),
      :param_type             => get_opt(:param),
      :param_value            => get_opt('param_value'),
      :param_value_num        => get_opt('param_value_num'),
      :dispersion_type        => get_opt(:dispersion),
      :dispersion_value       => get_opt('dispersion_value'),
      :dispersion_value_num   => get_opt('dispersion_value_num'),
      :dispersion_lower_limit => get_opt('lower_limit'),
      :dispersion_upper_limit => get_opt('upper_limit'),
      :explanation_of_na      => xml.text,
    }
  end

end
