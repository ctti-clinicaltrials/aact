class DropWithdrawal < StudyRelationship
  belongs_to :result_group

  def self.create_all_from(opts)
    DropWithdrawal.import(self.nested_pop_create(opts.merge(:name=>'drop_withdraw_reason')))
  end

  def self.nested_pop_create(opts)
    name=opts[:name]
    all=opts[:xml].xpath("//#{name}_list").xpath(name)
    col=[]
    xml=all.pop
    while xml
      opts[:reason]=xml.xpath('title').text
      opts[:period]=xml.parent.parent.xpath('title').text
      groups=xml.xpath("participants_list").xpath('participants')
      group=groups.pop
      while group
        col << create_from(opts.merge(:xml=>group))
        group=groups.pop
      end
      xml=all.pop
    end
    col.flatten
  end

  def get_group
    opts[:groups].each{|g|
      return g if g.ctgov_group_code==gid
    }
  end

  def gid
    get_attribute('group_id')
  end

  def attribs
    {
      :reason => get_opt(:reason),
      :period => get_opt(:period),
      :participant_count => get_attribute('count').to_i,
      :ctgov_group_code => gid,
    }
  end

  def self.extract_summary
    column_headers= ['nct_id','period','group','participant_count','reason']

    CSV.open("#{self.name}_Summary.csv", "wb", :write_headers=> true, :headers => column_headers) {|csv|
      all.each{|x|
        csv << [x.nct_id,
                x.period,
                x.result_group.title,
                x.participant_count,
                x.reason]
      }
    }
  end

end
