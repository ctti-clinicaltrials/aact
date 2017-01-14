class OutcomeMeasurement < StudyRelationship
  belongs_to :outcome, autosave: true
  belongs_to :result_group, autosave: true

  def self.create_all_from(opts)
    original_xml=opts[:xml]
    col=[]

    xml=opts[:xml]
    classes=xml.xpath("class_list").xpath('class')
    return col if classes.blank?
    a_class=classes.pop
    while a_class
      opts[:classification]=a_class.xpath('title').text

      categories=a_class.xpath("category_list").xpath('category')
      category=categories.pop
      if category.blank?
        col << new.create_from(opts)
      else
        while category
          opts[:category]=category.xpath('title').text
          measurements=category.xpath("measurement_list").xpath('measurement')
          gr=measurements.pop
          if gr.blank?
            col << new.create_from(opts)
          else
            while gr
              opts[:param_value]=gr.attribute('value').try(:value)
              if opts[:param_value] == 'NA'
                opts[:param_value_num]=''
              else
                opts[:param_value_num]=opts[:param_value]
              end
              opts[:dispersion_value]=gr.attribute('spread').try(:value)
              if opts[:dispersion_value] == 'NA'
                opts[:dispersion_value_num]=''
              else
                opts[:dispersion_value_num]=opts[:dispersion_value]
              end

              opts[:lower_limit]=gr.attribute('lower_limit').try(:value)
              opts[:upper_limit]=gr.attribute('upper_limit').try(:value)
              opts[:group_id]=gr.attribute('group_id').try(:value)
              opts[:explanation_of_na]=gr.text
              om = new.create_from(opts)
              col << om
              gr=measurements.pop
            end
          end
          category=categories.pop
        end
      end
      a_class=classes.pop
    end
    col
  end

  def gid
    opts[:group_id]
  end

  def attribs
    {
      :result_group           => get_group(opts[:groups]),
      :outcome                => get_opt(:outcome),
      :classification         => get_opt('classification'),
      :category               => get_opt('category'),
      :title                  => get_opt(:title),
      :description            => get_opt(:description),
      :units                  => get_opt(:units),
      :ctgov_group_code       => get_opt('group_id'),
      :param_type             => get_opt('param_type'),
      :param_value            => get_opt('param_value'),
      :param_value_num        => get_opt('param_value_num'),
      :dispersion_type        => get_opt('dispersion_type'),
      :dispersion_value       => get_opt('dispersion_value'),
      :dispersion_value_num   => get_opt('dispersion_value_num'),
      :dispersion_lower_limit => get_opt('lower_limit'),
      :dispersion_upper_limit => get_opt('upper_limit'),
      :explanation_of_na      => get_opt('explanation_of_na'),

    }
  end

end
