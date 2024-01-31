require 'rails_helper'

RSpec.describe ResultAgreement do
  describe 'ResultAgreement#mapper' do
    it 'study should have expected result_agreement info' do
      expected_data = 
        { 
          nct_id: 'NCT01340027', 
          pi_employee: "No",
          restriction_type: "OTHER",
          restrictive_agreement: "Yes",
          other_details: "Institute and/or Principal Investigator may publish trial data generated at their specific study site after Sponsor publication of the multi-center data. Sponsor must receive a site's manuscript at least 90 days prior to publication for review and comment."
        }

      hash = JSON.parse(File.read('spec/support/json_data/result_agreement.json'))
      
      processor = StudyJsonRecord::ProcessorV2.new(hash)
      expect(ResultAgreement.mapper(processor)).to eq(expected_data)
    end
  end  
end