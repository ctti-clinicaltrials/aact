class OutcomeMeasure < StudyRelationship
  belongs_to :outcome, inverse_of: :outcome_measures, autosave: true
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
        opts[:param]=xml.xpath('param').text
        opts[:dispersion]=xml.xpath('dispersion').text
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
                opts[:value]=gr.attribute('value').try(:value)
                opts[:spread]=gr.attribute('spread').try(:value)
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
      :lower_limit => get_attribute('lower_limit'),
      :upper_limit => get_attribute('upper_limit'),
      :title => get_opt(:title),
      :units => get_opt(:units),
      :param => get_opt(:param),
      :ctgov_group_code => get_opt(:group_id),
      :category => get_opt(:category),
      :measure_value => get_opt(:value),
      :spread => get_opt(:spread),
      :dispersion => get_opt(:dispersion),
      :description => get_opt(:description),
      :outcome => get_opt(:outcome),
      :result_group => get_group
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
    #puts "OutcomeMeasure - get_group. Didn't find the group....creating....  "
    # if group doesn't yet exist, create it...
    new_group=ResultGroup.create_from(opts)
    opts[:groups] << new_group
    return new_group
  end

end
