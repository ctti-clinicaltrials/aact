class OutcomeAnalysis < StudyRelationship
  belongs_to :outcome
  belongs_to :group

  def self.create_all_from(opts)
    all=opts[:xml].xpath("analysis_list").xpath('analysis')
    col=[]
    xml=all.pop
		return col if xml.blank?
    while xml
			opts[:xml]=xml
			opts[:title]=xml.xpath('title')
			opts[:non_inferiority]=xml.xpath('non_inferiority').inner_html
			opts[:non_inferiority_description]=xml.xpath('non_inferiority_desc').inner_html
			opts[:p_value]=xml.xpath('p_value').inner_html
			opts[:param_type]=xml.xpath('param_type').inner_html
			opts[:param_value]=xml.xpath('param_value').inner_html
			opts[:dispersion_type]=xml.xpath('dispersion_type').inner_html
			opts[:dispersion_value]=xml.xpath('dispersion_value').inner_html
			opts[:ci_percent]=xml.xpath('ci_percent').inner_html
			opts[:ci_n_sides]=xml.xpath('ci_n_sides').inner_html
			opts[:ci_lower_limit]=xml.xpath('ci_lower_limit').inner_html
			opts[:ci_upper_limit]=xml.xpath('ci_upper_limit').inner_html
			opts[:method]=xml.xpath('method').inner_html
			opts[:group_description]=xml.xpath('groups_desc').inner_html
			opts[:method_description]=xml.xpath('method_desc').inner_html
			opts[:estimate_description]=xml.xpath('estimate_desc').inner_html
			col << pop_create(opts.merge(:name=>'group_id'))
		  xml=all.pop
		end
    col.flatten
  end

  def attribs
    {
     :ctgov_group_id => xml.inner_html,
     :ctgov_group_enumerator => integer_in(xml.inner_html),
     :title => get_opt(:title),
     :non_inferiority => get_opt(:non_inferiority),
     :non_inferiority_description => get_opt(:non_inferiority_description),
     :p_value => get_opt(:p_value),
     :param_type => get_opt(:param_type),
     :param_value => get_opt(:param_value),
     :dispersion_type => get_opt(:dispersion_type),
     :dispersion_value => get_opt(:dispersion_value),
     :ci_percent => get_opt(:ci_percent),
     :ci_n_sides => get_opt(:ci_n_sides),
     :ci_lower_limit => get_opt(:ci_lower_limit),
     :ci_upper_limit => get_opt(:ci_upper_limit),
     :method => get_opt(:method),
     :group_description => get_opt(:group_description),
     :method_description => get_opt(:method_description),
     :estimate_description => get_opt(:estimate_description),
		 :outcome => get_opt(:outcome),
		 :group => get_group,
    }
  end

	def gid
		integer_in(opts[:xml].inner_html)
	end

	def get_group
		opts[:groups].each {|g| return g if g.ctgov_group_enumerator==gid }
	end

  def conditionally_create_from(opts)
		@opts=opts
    return nil if opts[:xml].inner_html != opts[:group_id_of_interest]
    create_from(opts)
  end

end
