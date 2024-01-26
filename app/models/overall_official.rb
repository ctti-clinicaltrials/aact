class OverallOfficial < ApplicationRecord

  def self.top_level_label
    '//overall_official'
  end

  def self.mapper(json)
    return unless json.contacts_location_module

    nct_id = json.protocol_section.dig('identificationModule', 'nctId')
    overall_officials = json.contacts_location_module['overallOfficials']
    return unless overall_officials

    collection = []
    overall_officials.each do |overall_official|
      collection << {
                      nct_id: nct_id,
                      name: overall_official['name'],
                      affiliation: overall_official['affiliation'],
                      role: overall_official['role']
                    }
    end

    collection
  end

end
