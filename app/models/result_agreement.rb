class ResultAgreement < ApplicationRecord

  def self.mapper(json)
    return unless json.protocol_section

    nct_id = json.protocol_section.dig('identificationModule', 'nctId')
    certain_agreement = json.results_section.dig('moreInfoModule', 'certainAgreement')

    map = {
      false => "No",
      true => "Yes"
    }

    {
      nct_id: nct_id,
      pi_employee: map[certain_agreement['piSponsorEmployee']],
      restriction_type: certain_agreement['restrictionType'],
      restrictive_agreement: map[certain_agreement['restrictiveAgreement']],
      other_details: certain_agreement['otherDetails']
    }
  end

end
