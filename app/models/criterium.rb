class Criterium < StudyRelationship
  self.table_name = 'criteria'

  def self.create_all_from(opts)
    opts[:xml].xpath('//criteria').collect{|xml|
      test_input = xml.text
      if (test_input.include?('Inclusion Criteria:') and test_input.include?('Exclusion Criteria:'))
        incl=test_input.split('Exclusion Criteria:').first
        excl=test_input.split('Exclusion Criteria:').last
      elsif test_input.include?('Inclusion Criteria:')
        incl=test_input
        excl=''
      elsif test_input.include?('Exclusion Criteria:')
        incl=''
        excl=test_input
      else
        puts "ERROR:  Unexpected criteria"
        return
      end
      create_each(incl, 'inclusion', opts)
      create_each(excl, 'exclusion', opts)
    }
  end

  def self.create_each(collection, type, opts)
    cntr = 1
    collection.split("\n\n").each{ |criterium|
      c=new.create_from({:xml=>criterium, :type=>type, :nct_id=>opts[:nct_id], :cntr => cntr})
      if !c.name.nil? and c.name.size > 1
        c.save!
        cntr = cntr + 1
      end
    }
  end

  def attribs
    nm     = clean_string(get_opt('xml'))
    return {} if nm.nil?
    order  = get_order_num(nm, get_opt('cntr'))
    dnm    = nm.downcase
    {
      :nct_id        => get_opt(:nct_id),
      :criteria_type => get_opt('type'),
      :name          => nm,
      :downcase_name => dnm,
      :order_number  => order
    }
  end

  def clean_string(str)
    return nil if str.downcase.include? 'inclusion criteria:' or str.downcase.include? 'exclusion criteria:'
    str.strip.gsub("\n",' ').gsub(/\s+/, ' ')
  end

  def get_order_num(nm, derived_cntr)
    prefix = nm.split(' ').first if nm
    return derived_cntr if prefix.nil?
    order_defined_in_criterium = prefix.strip.gsub(".",'').gsub(":",'')
    is_a_num = Integer(order_defined_in_criterium) rescue false
    if !is_a_num
      return derived_cntr
    else
      # cleanup the name - remove prefix and any leading spaces
      nm.slice! prefix
      nm.strip!
      return Integer(order_defined_in_criterium)
    end
  end

end
