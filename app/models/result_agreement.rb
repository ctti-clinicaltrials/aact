class ResultAgreement < ApplicationRecord

  def self.mapper(json)
    return unless json.protocol_section

    nct_id = json.protocol_section.dig('identificationModule', 'nctId')
    certain_agreement = results_section.dig('moreInfoModule', 'certainAgreement')

    {
      nct_id: nct_id,
      pi_employee: certain_agreement['piSponsorEmployee'],
      restrictive_agreement: certain_agreement['restrictiveAgreement'],
      restriction_type: certain_agreement['restrictionType'],
      other_details: certain_agreement['otherDetails']
    }
  end

end
