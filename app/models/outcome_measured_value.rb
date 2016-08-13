class OutcomeMeasuredValue < StudyRelationship
  belongs_to :outcome, autosave: true

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
            opts[:measure_category]=category.xpath('sub_title').text
            col << new.create_from(opts)
            category=categories.pop
          end




            #measurements=category.xpath("measurement_list").xpath('measurement')
            #gr=measurements.pop
            #if gr.blank?
            #  m= new.create_from(opts)
						#	puts "gr.blank?"
						#	puts m
            #  col << m
            #else
            #  while gr
            #    opts[:param_value]=gr.attribute('value').try(:value)
            #    opts[:dispersion_value]=gr.attribute('spread').try(:value)
            #    m=new.create_from(opts)
  		      #    #if opts[:title]=='Percentage of Participants With Change in MIRCERA Treatment'
						#		  puts "while gr"
			      #      puts m.inspect
			      #    #end
			      #    col << m
            #    gr=measurements.pop
            #  end
            #end




       end
       xml=all.pop
    end
    col
  end

  def attribs
    {
      :title                  => get_opt(:measure_title),
      :description            => get_opt(:measure_description),
      :units                  => get_opt(:measure_units),
      :category               => get_opt(:measure_category),
      :param_type             => get_opt(:param_type),
      :dispersion_type        => get_opt(:dispersion_type),
      :param_value            => get_opt(:value),
      :dispersion_value       => get_opt(:dispersion_value),
      :dispersion_lower_limit => get_attribute('lower_limit'),
      :dispersion_upper_limit => get_attribute('upper_limit'),
      :outcome                => get_opt(:outcome),
    }
  end

end
