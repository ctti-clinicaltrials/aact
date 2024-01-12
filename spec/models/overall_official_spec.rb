require 'rails_helper'

RSpec.describe OverallOfficial do

  describe 'OverallOfficial#mapper' do
    it 'uses JSON API to generate data that will be inserted into the overall officials data table' do
      expected_data = [
        { 
          nct_id: 'NCT03475563', 
          name: 'Imanol Otaegui, MD', 
          affiliation: "Hospital Universitari Vall d'hebron Barcelona, Spain", 
          role: 'PRINCIPAL_INVESTIGATOR' 
        }
      ]
      hash = JSON.parse(File.read('spec/support/json_data/NCT03475563.json'))
      processor = StudyJsonRecord::ProcessorV2.new(hash)
      expect(OverallOfficial.mapper(processor)).to eq(expected_data)
    end
  end 
   
end  