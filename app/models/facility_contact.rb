class FacilityContact < StudyRelationship
  belongs_to :facility, inverse_of: :facility_contacts, autosave: true

  attr_accessor :attribs

  extend Enumerize

  enumerize :contact_type, in: %w(
    regular
    backup
  )

  def initialize
    super
    @attribs = {}
  end

  def self.create_all_from(opts)
    nct_id = opts.document.xpath('//nct_id').text
    results = []

    if opts.xpath('contact').present?
      results << opts.xpath('contact').map do |contact|
        fc = new

        fc.attribs = Hash.from_xml(contact.to_xml)['contact'].merge({
          'nct_id' => nct_id,
          'contact_type' => 'regular'
        })
        fc.attribs = fc.sanitize_attribs(fc.attribs)
        fc.create_from(opts)
      end
    end

    if opts.xpath('contact_backup').present?
      results << opts.xpath('contact_backup').map do |contact|
        fc = new
        fc.attribs = Hash.from_xml(contact.to_xml)['contact_backup'].merge({
          'nct_id' => nct_id,
          'contact_type' => 'backup'
        })
        fc.attribs = fc.sanitize_attribs(fc.attribs)
        fc.create_from(opts)
      end
    end

    results.flatten
  end

  def attribs_map
    # keys are the old values, values are what we want to transform them into
    {
      'last_name' => 'name',
      'phone' => 'phone',
      'email' => 'email',
      'nct_id' => 'nct_id',
      'contact_type' => 'contact_type'
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

