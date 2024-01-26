class Sponsor < ApplicationRecord
  
  def self.mapper(json)
    return unless json.protocol_section

    sponsor_collaborators_module = json.protocol_section['sponsorCollaboratorsModule']
    return unless sponsor_collaborators_module

    collaborators = sponsor_collaborators_module['collaborators']
    lead_sponsor = sponsor_collaborators_module['leadSponsor']
    return unless collaborators || lead_sponsor

    collection = []
    collection << sponsor_info(json, lead_sponsor, 'leadSponsor') if lead_sponsor
    return collection unless collaborators

    collaborators.each do |collaborator|
      info = sponsor_info(json, collaborator, 'collaborators')
      collection << info if info
    end

    collection
  end

  def self.sponsor_info(json, sponsor_hash, sponsor_type='leadSponsor')
    return if sponsor_hash.empty?

    nct_id = json.protocol_section.dig('identificationModule', 'nctId')

    {
      nct_id: nct_id,
      agency_class: sponsor_hash['class'],
      lead_or_collaborator: sponsor_type =~ /Lead/i ? 'lead' : 'collaborator',
      name: sponsor_hash['name']
    }
  end

end
