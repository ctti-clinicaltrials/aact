class Criterium < StudyRelationship
  self.table_name = 'criteria'

  def self.create_all_from(opts)
    opts[:xml].xpath('//criteria').collect{|xml|
      arr=xml.text.split('Exclusion criteria:')
      arr=xml.text.split('Exclusion Criteria:') if arr.nil?
      arr=xml.text.downcase.split('exclusion criteria') if arr.nil?
      return if arr.nil?
      incl = arr.first
      excl = arr.last
      create_each(incl, 'inclusion', opts)
      create_each(excl, 'exclusion', opts)
    }
  end

  def self.create_each(collection, type, opts)
    cntr = 1
    collection.split("\n\n").each{ |criterium|
      c=new.create_from({:xml=>criterium, :type=>type, :nct_id=>opts[:nct_id], :cntr => cntr})
      if c.name and !c.name.include? "criteria:"
        c.save!
        cntr = cntr + 1
      end
    }
  end

  def attribs
    nm    = clean_string(get_opt('xml'))
    order = get_order_num(nm, get_opt('cntr'))
    {
      :nct_id        => get_opt(:nct_id),
      :criteria_type => get_opt('type'),
      :name          => nm.strip!,
      :downcase_name => nm.downcase.strip!,
      :order_number  => order
    }
  end

  def clean_string(str)
    str.strip.gsub("\n",' ').gsub(/\s+/, ' ')
  end

  def get_order_num(nm, derived_cntr)
    prefix = nm.split(' ').first
    return derived_cntr if prefix.nil?
    order_defined_in_criterium = prefix.strip.gsub(".",'').gsub(":",'')
    is_a_num = Integer(order_defined_in_criterium) rescue false
    if !is_a_num
      derived_cntr
    else
      nm.slice! prefix
      Integer(order_defined_in_criterium)
    end
  end

end
