class Design < StudyRelationship
	attr_accessor :source

  def attribs
    {
		:description => source,
		:primary_purpose => get_value_for('Primary Purpose:'),
		:time_perspective => get_value_for('Time Perspective:'),
		:observational_model => get_value_for('Observational Model:'),
		:intervention_model => get_value_for('Intervention Model:'),
		:endpoint_classification => get_value_for('Endpoint Classification:'),
    :allocation => get_value_for('Allocation:'),
    :masking => get_masking,
    :masked_roles => get_masked_roles,
		}
  end

	def source
		@source ||= get_opt(:xml).xpath("//study_design").try(:inner_html)
	end

	def labels
		['Allocation:','Endpoint Classification:','Intervention Model:','Masking:','Primary Purpose:','Time Perspective:','Observational Model:']
	end

	def get_masking
	  val=get_value_for('Masking:')
		val.split('(').first.try(:strip) if val
	end

	def get_masked_roles
	  val=get_value_for('Masking:')
		result=val.split('(').last if val
		result.tr('()', '') if result
	end

	def get_value_for(design_label)
		i=source.index(design_label)  # find label in the string
		return nil if !i  # if not found, return nil
		i=i+design_label.size  # advance past the label to get to the value
		str=source[i..source.size]
		n=0  # will be set to length of value string
		labels.each{|label|  # iterate thru all possible labels.  Find next one
			i=str.index(label)
			if i
				if n==0  # length of value hasn't yet been set.  Set it.
					n=i
				else
					if i < n  # seems we found a label nearer the front of the value.  Use it
						n=i
					end
				end
			end
		}
		if n > 0
			n=n-3
		else
		  n=str.size
		end
		str[0..n].strip
	end

end
