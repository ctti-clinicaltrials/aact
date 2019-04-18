class Criterium < StudyRelationship
  self.table_name = 'criteria'
  belongs_to :parent, class_name: 'Criterium'
  has_many   :children, class_name: 'Criterium', foreign_key: 'parent_id'

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
        # TODO.   Report this error properly
        puts "ERROR:  Unexpected criteria"
        return
      end
      create_each(incl, 'inclusion', opts)
      create_each(excl, 'exclusion', opts)
    }
  end

  def self.create_each(collection, type, opts)
    cntr = 1
    previous_cntr = 1
    previous_indent_size = 100000
    previous_criterium = nil
    parent_criterium = nil
    collection.split("\n\n").each{ |criterium|
      indent_size = criterium.count(' ') - criterium.lstrip.count(' ')
      if indent_size == previous_indent_size
        # this must be a sibling to the previous criterium
      elsif indent_size > previous_indent_size
        # this must be a child to the previous criterium
        parent_criterium = previous_criterium
        previous_indent_size = indent_size
        previous_cntr = cntr
        cntr = 1
      elsif indent_size < previous_indent_size
        # seems we've finished with the children of the previous criterium
        parent_criterium = nil
        previous_indent_size = indent_size
        cntr = previous_cntr
      end

      c=new.create_from({:xml=>criterium, :type=>type, :nct_id=>opts[:nct_id], :cntr => cntr, :parent => parent_criterium})
      if !c.name.nil? and c.name.size > 1
        c.save!
        previous_criterium = c
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
      :nct_id               => get_opt(:nct_id),
      :parent               => get_opt(:parent),
      :criteria_type        => get_opt('type'),
      :name                 => nm,
      :downcase_name        => dnm,
      :order_number         => order
    }
  end

  def clean_string(str)
    return nil if str.downcase.include? 'inclusion criteria:' or str.downcase.include? 'exclusion criteria:'
    val=str.strip.gsub("\n",' ').gsub(/\s+/, ' ')
    val.gsub(/^[-] /, '')
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
