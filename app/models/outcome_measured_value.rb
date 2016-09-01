class OutcomeMeasuredValue < StudyRelationship
  belongs_to :outcome, autosave: true
  belongs_to :result_group, autosave: true

  def self.create_all_from(opts)
    all=opts[:outcome_xml].xpath("measure_list").xpath('measure')

    col=[]
    xml=all.pop
    while xml
      opts[:measure_title]=xml.xpath('title').text
      opts[:measure_description]=xml.xpath('description').text
      opts[:measure_units]=xml.xpath('units').text
      opts[:param_type]=xml.xpath('param').text
      opts[:dispersion_type]=xml.xpath('dispersion').text
      categories=xml.xpath("category_list").xpath('category')
      category=categories.pop
      if category.blank?
        col << new.create_from(opts)
      else
          while category
            opts[:category]=category.xpath('sub_title').text
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
                opts[:ctgov_group_code]=gr.attribute('group_id').try(:value)
                opts[:explanation_of_na]=gr.text
                om = new.create_from(opts)
                col << om
                gr=measurements.pop
              end
            end

            category=categories.pop
          end

       end
       xml=all.pop
    end
    col
  end

  def attribs
    {
      :result_group           => get_group(opts[:groups]),
      :ctgov_group_code       => get_opt('ctgov_group_code'),
      :title                  => get_opt('measure_title'),
      :description            => get_opt('measure_description'),
      :units                  => get_opt('measure_units'),
      :category               => get_opt('category'),
      :param_type             => get_opt('param_type'),
      :param_value            => get_opt('param_value'),
      :param_value_num        => get_opt('param_value_num'),
      :dispersion_type        => get_opt('dispersion_type'),
      :dispersion_value       => get_opt('dispersion_value'),
      :dispersion_value_num   => get_opt('dispersion_value_num'),
      :dispersion_lower_limit => get_opt('lower_limit'),
      :dispersion_upper_limit => get_opt('upper_limit'),
      :explanation_of_na      => get_opt('explanation_of_na'),
      :outcome                => get_opt('outcome'),
    }
  end

  def gid
    opts[:ctgov_group_code]
  end

end
