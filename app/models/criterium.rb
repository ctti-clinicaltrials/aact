class Criterium < StudyRelationship
  self.table_name = 'criteria'
  belongs_to :parent, class_name: 'Criterium'
  has_many   :children, class_name: 'Criterium', foreign_key: 'parent_id'

  def self.create_all_from(opts)
    criteria = opts[:xml].xpath('//criteria')
    return if criteria.nil?
    criteria.collect{|xml|
      test_input=standardize_tags(xml.text)

      if (test_input.include?('inclusion criteria') and test_input.include?('exclusion criteria'))
        above_excl    = test_input.split('exclusion criteria').first # assume 'exclusion criteria marks end of inclusion
        below_incl    = test_input.split('inclusion criteria').last

        # There might be multiple exclusion sections, so break the whole text blob on string 'exclusion criteria'
        # then delete the first one that will almost certainly be the 'inclusion criteria'
        # That way we have all exclusion criteria sections if there are more than 1
        excl_sections = test_input.split('exclusion criteria')
        excl_sections.delete_at(0) if excl_sections.first.include? 'inclusion criteria'

        other         = above_excl.split('inclusion criteria').first # anything before the first 'incl' tag is 'other'
        incl_sections = above_excl.split('inclusion criteria')  #  break up possible inclusion sections
        incl_sections.delete_at(0) if other.size > 0

      elsif test_input.include?('inclusion criteria')
        other          = test_input.split('inclusion criteria').first
        incl_sections  = test_input.split('inclusion criteria')
        excl_sections  = []

      elsif test_input.include?('exclusion criteria')
        other          = test_input.split('exclusion criteria').first
        excl_sections  = test_input.split('exclusion criteria')
        incl_sections  = []
      else
        # TODO.   Report this error properly
        other = test_input
      end
      create_each(other, 'other', opts) if !other.nil?
      incl_sections.each {|incl| create_each(incl,  'inclusion', opts) } if !incl_sections.nil?
      excl_sections.each {|excl| create_each(excl,  'exclusion', opts) } if !excl_sections.nil?
    }
  end

  def self.standardize_tags(xml)
      val = xml.gsub('EXCLUSION CRITERIA','exclusion criteria')
      val = val.gsub('Exclusion Criteria','exclusion criteria')
      val = val.gsub('Exclusion criteria','exclusion criteria')
      val = val.gsub('exclusion criteria','exclusion criteria')
      val = val.gsub('exclusion Criteria','exclusion criteria')

      val = val.gsub('INCLUSION CRITERIA','inclusion criteria')
      val = val.gsub('Inclusion Criteria','inclusion criteria')
      val = val.gsub('Inclusion criteria','inclusion criteria')
      val = val.gsub('inclusion criteria','inclusion criteria')
      val = val.gsub('inclusion Criteria','inclusion criteria')
  end

  def self.create_each(collection, type, opts)
    return if collection.nil?
    cntr = 1
    previous_cntr = 1
    lev = 1
    indent_diff = 0
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
        indent_diff = indent_size - previous_indent_size
        previous_indent_size = indent_size
        previous_cntr = cntr
        cntr = 1
        lev = lev + 1
      elsif indent_size < previous_indent_size
        # seems we've finished with the children of the previous criterium
        parent_criterium = nil

        # save the indent level.  The next criteria might be several levels back, so keep subtracting the indent size diff from previous
        # until it's at the current indent location.
        i = previous_indent_size
        while indent_size < i
          if indent_diff == 0
            i = indent_size
          else
            i = i - indent_diff
            lev = lev - 1 if i == indent_size
          end
        end

        previous_indent_size = indent_size
        cntr = previous_cntr
      end

      c=new.create_from({:xml=>criterium, :type=>type, :nct_id=>opts[:nct_id], :cntr => cntr, :parent => parent_criterium, :level => lev})
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
      :level                => get_opt(:level),
      :criterium_type       => get_opt('type'),
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
