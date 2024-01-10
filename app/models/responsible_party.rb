class ResponsibleParty < ApplicationRecord

  def self.top_level_label
    '//responsible_party'
  end

  def self.create_all_from(opts)
    objects = super
    import(objects)
  end

  def name_field(opts)
    if opts[:xml].xpath('name_title').present?
      return get('name_title')
    else
      return get('investigator_full_name')
    end
  end

  # def attribs
  #   {
  #     :responsible_party_type => get('responsible_party_type'),
  #     :affiliation => get('investigator_affiliation'),
  #     :organization => get('organization'),
  #     :title => get('investigator_title'),
  #     :name => get_name,
  #   }
  # end

  def self.mapper(json)

    # return unless protocol_section

    # responsible_party = protocol_section.dig('sponsorCollaboratorsModule', 'responsibleParty')
    # return unless responsible_party
    return unless json.protocol_section
    nct_id = json.protocol_section.dig('identificationModule', 'nctId')
    responsible_party = json.protocol_section.dig('sponsorCollaboratorsModule', 'responsibleParty')

      {
        nct_id: nct_id,
        responsible_party_type: responsible_party['type'],
        name: responsible_party['investigatorFullName'],
        title: responsible_party['investigatorTitle'],
        organization: responsible_party['leadSponsor'],
        affiliation: responsible_party['investigatorAffiliation']
      }
    # ask Ramiro about array of collaborators 
  end

  # def get_name
  #   n=get('investigator_full_name')
  #   !n.blank? ? n : get('name_title')
  # end

end
