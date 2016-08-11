class OutcomeMeasuredValue < StudyRelationship
  belongs_to :outcome
  belongs_to :result_group
  attr_accessor :category_xml

  def self.create_all_from(opts)
    all=opts[:xml].xpath("measure_list").xpath('measure')
    col=[]
    xml=all.pop
    if xml.blank?
      return []
    else
      while xml
        opts[:title]=xml.xpath('title').text
        opts[:units]=xml.xpath('units').text
        opts[:param_type]=xml.xpath('param').text
        opts[:dispersion_type]=xml.xpath('dispersion').text
        opts[:description]=xml.xpath('description').text
        categories=xml.xpath("category_list").xpath('category')
        category=categories.pop
        if category.blank?
          col << new.conditionally_create_from(opts)
        else
          while category
            opts[:category]=category.xpath('sub_title').text
            grps=category.xpath("measurement_list").xpath('measurement')
            gr=grps.pop
            if gr.blank?
              col << new.conditionally_create_from(opts)
            else
              while gr
                opts[:group_id]=gr.attribute('group_id').try(:value)
                opts[:param_value]=gr.attribute('value').try(:value)
                opts[:dispersion_value]=gr.attribute('spread').try(:value)
                col << new.conditionally_create_from(opts)
                gr=grps.pop
              end
            end
            category=categories.pop
          end
        end
        xml=all.pop
      end
    end
    outcome_measures = col.flatten.compact
    outcome_measures.map(&:attributes)
  end

  def attribs
    {
      :ctgov_group_code       => get_opt(:group_id),
      :result_group           => get_group,
      :title                  => get_opt(:title),
      :category               => get_opt(:category),
      :description            => get_opt(:description),
      :param_type             => get_opt(:param_type),
#      :param_value            => get_opt(:value),
      :dispersion_type        => get_opt(:dispersion_type),
      :dispersion_value       => get_opt(:dispersion_value),
      :dispersion_lower_limit => get_attribute('lower_limit'),
      :dispersion_upper_limit => get_attribute('upper_limit'),
      :units                  => get_opt(:units),
      :outcome                => get_opt(:outcome),
    }
  end

  def conditionally_create_from(opts)
    return nil if opts[:group_id] != opts[:group_id_of_interest]
    create_from(opts)
  end

  def gid
    opts[:group_id_of_interest]
  end

  def get_group
    # TODO duplicate code in outcome.rb
    opts[:groups].each {|g| return g if g.ctgov_group_code==gid }
    # if group doesn't yet exist, create it...
    new_group=ResultGroup.create_from(opts)
    opts[:groups] << new_group
    return new_group
  end

end
