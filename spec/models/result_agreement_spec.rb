require 'rails_helper'

RSpec.describe ResultAgreement do
  describe 'ResultAgreement#mapper' do
    it 'study should have expected result_agreement info' do
      expected_data = [
        { 
          nct_id: 'NCT03064438', 
          document_type: 'Study Protocol', 
          has_protocol: true,
          has_icf: false, 
          has_sap: false, 
          document_date: Date.parse('Sat, 05 Aug 2017'),
          url: 'https://ClinicalTrials.gov/ProvidedDocs/38/NCT03064438/Prot_000.pdf'
        },
        { 
          nct_id: 'NCT03064438', 
          document_type: 'Statistical Analysis Plan', 
          has_protocol: false,
          has_icf: false, 
          has_sap: true, 
          document_date: Date.parse('Fri, 11 May 2018'),
          url: 'https://ClinicalTrials.gov/ProvidedDocs/38/NCT03064438/SAP_001.pdf'
        }
      ]
      hash = JSON.parse(File.read('spec/support/json_data/NCT03064438.json'))
      processor = StudyJsonRecord::ProcessorV2.new(hash)
      expect(ResultAgreement.mapper(processor)).to eq(expected_data)
    end
  end  
end