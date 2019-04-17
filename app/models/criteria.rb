class Criteria < StudyRelationship

  def self.create_all_from(opts)
    opts[:xml].xpath('//criteria').collect{|xml|
      arr=xml.text.downcase.split('exclusion')
      incl = arr.first
      excl = arr.last
      incl.split("\n\n").each{ |criteria|
        c=new({:name=>criteria.strip, :nct_id=>opts[:nct_id], :criteria_type=>'inclusion'})
        c.save! if !c.name.include? "criteria:" and c.name.size > 0
      }
      excl.split("\n\n").each{ |criteria|
        c=new({:name=>criteria.strip, :nct_id=>opts[:nct_id], :criteria_type=>'exclusion'})
        c.save! if !c.name.include? "criteria:" and c.name.size > 0
      }
    }
  end

end
