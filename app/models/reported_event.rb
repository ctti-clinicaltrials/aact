class ReportedEvent < StudyRelationship
  extend FastCount

  belongs_to :result_group

  def self.create_all_from(opts)
    nct_id=opts[:nct_id]
    opts[:xml]=opts[:xml].xpath("//reported_events")
    opts[:time_frame]=opts[:xml].xpath('time_frame').text
    opts[:description]=opts[:xml].xpath('desc').text
    opts[:result_type]='Reported Event'
    opts[:groups]=create_group_set(opts)

    event_type='serious'
    opts[:type]=event_type
    outter_xml=opts[:xml].xpath("//#{event_type}_events")
    event_collection=[]
    outter_xml.collect{|xml|
      opts[:frequency_threshold]=xml.xpath('frequency_threshold').text
      opts[:default_vocab]=xml.xpath('default_vocab').text
      opts[:default_assessment]=xml.xpath('default_assessment').text
      cat_xmls=outter_xml.xpath("category_list").xpath('category')
      c_xml=cat_xmls.pop
      if c_xml.nil?
        puts "TODO  need to account for no categories"
      else
        while c_xml
          opts[:category]=c_xml.xpath('title').text
          event_xmls=c_xml.xpath("event_list").xpath('event')
          e_xml=event_xmls.pop
          if e_xml.nil?
            puts "TODO  need to account for no events"
          else
            while e_xml
              opts[:title]=e_xml.xpath('sub_title').text
              count_xmls=e_xml.xpath("counts")
              o_xml=count_xmls.pop
              if o_xml.nil?
                puts "TODO  need to account for no counts"
              else
                while o_xml
                  opts[:group_id]=o_xml.attribute('group_id').try(:value)
                  opts[:event_count]=o_xml.attribute('events').try(:value)
                  opts[:subjects_affected]=o_xml.attribute('subjects_affected').try(:value)
                  opts[:subjects_at_risk]=o_xml.attribute('subjects_at_risk').try(:value)
                  event_collection << self.new.create_from(opts)
                  o_xml=count_xmls.pop
                end
              end
              e_xml=event_xmls.pop
            end
          end
          c_xml=cat_xmls.pop
        end
      end
    }
    opts[:type]='serious'
    serious=get_events(opts)
    opts[:type]='other'
    other=get_events(opts)

    import((serious + other).flatten)
  end

  # TODO  this can and should be refactored in 100 different ways, but it works for now.
  def self.get_events(opts)
    event_type=opts[:type]
    outter_xml=opts[:xml].xpath("//#{event_type}_events")
    event_collection=[]
    outter_xml.collect{|xml|
      opts[:frequency_threshold]=xml.xpath('frequency_threshold').text
      opts[:default_vocab]=xml.xpath('default_vocab').text
      opts[:default_assessment]=xml.xpath('default_assessment').text
      cat_xmls=outter_xml.xpath("category_list").xpath('category')
      c_xml=cat_xmls.pop
      if c_xml.nil?
        puts "TODO  need to account for no categories"
      else
        while c_xml
          opts[:category]=c_xml.xpath('title').text
          event_xmls=c_xml.xpath("event_list").xpath('event')
          e_xml=event_xmls.pop
          if e_xml.nil?
            puts "TODO  need to account for no events"
          else
            while e_xml
              opts[:adverse_event_term]=e_xml.xpath('sub_title').text
              opts[:vocab]=e_xml.xpath('sub_title').attribute('vocab').try(:value)
              count_xmls=e_xml.xpath("counts")
              o_xml=count_xmls.pop
              if o_xml.nil?
                puts "TODO  need to account for no counts"
              else
                while o_xml
                  opts[:group_id]=o_xml.attribute('group_id').try(:value)
                  opts[:event_count]=o_xml.attribute('events').try(:value)
                  opts[:subjects_affected]=o_xml.attribute('subjects_affected').try(:value)
                  opts[:subjects_at_risk]=o_xml.attribute('subjects_at_risk').try(:value)
                  event_collection << self.new.create_from(opts)
                  o_xml=count_xmls.pop
                end
              end
              e_xml=event_xmls.pop
            end
          end
          c_xml=cat_xmls.pop
        end
      end
    }
    event_collection
  end

  def attribs
    {
      :result_group => get_group(opts[:groups]),
      :ctgov_group_code => gid,
      :organ_system => get_opt(:category),
      :event_type => get_opt(:type),
      :time_frame => get_opt(:time_frame),
      :description => get_opt(:description),
      :frequency_threshold => (get_opt(:frequency_threshold).to_i),
      :default_vocab => get_opt(:default_vocab),
      :default_assessment => get_opt(:default_assessment),
      :adverse_event_term => get_opt(:adverse_event_term),
      :event_count => get_opt(:event_count),
      :subjects_affected => get_opt(:subjects_affected),
      :subjects_at_risk => get_opt(:subjects_at_risk),
      :assessment => xml.xpath('assessment'),
      :vocab => get_opt(:vocab),
    }
  end

  def gid
    opts[:group_id]
  end

end
