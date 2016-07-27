class FacilityInvestigator < StudyRelationship
  belongs_to :facility, inverse_of: :facility_investigators, autosave: true

  attr_accessor :attribs

  def self.create_all_from(opts)
    nct_id = opts.document.xpath('//nct_id').text

    if opts.xpath('investigator').present?
      opts.xpath('investigator').map do |investigator|
        fc = new
        fc.attribs = Hash.from_xml(investigator.to_xml)['investigator'].merge({
          'nct_id' => nct_id,
        })
        fc.attribs = fc.sanitize_attribs(fc.attribs)
        fc.create_from(opts)
      end
    end
  end

  def attribs_map
    # keys are the old values, values are what we want to transform them into
    {
      'last_name' => 'name',
      'role' => 'role',
      'nct_id' => 'nct_id'
    }
  end

  def sanitize_attribs(attribs)
    attribs = attribs.dup

    attribs_map.each do |old, new|
      attribs[new] = attribs.delete(old)
    end

    attribs.delete_if { |k, v| !attribs_map.values.include?(k) }

    attribs
  end
end

