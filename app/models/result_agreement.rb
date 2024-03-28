class ResultAgreement < StudyRelationship
  add_mapping do
    {
      table: :result_agreements,
      root: [:resultsSection, :moreInfoModule, :certainAgreement],
      columns: [
        { name: :pi_employee, value: :piSponsorEmployee },
        { name: :restriction_type, value: :restrictionType },
        { name: :restrictive_agreement, value: :restrictiveAgreement },
        { name: :other_details, value: :otherDetails }
      ]
    }
  end
end
