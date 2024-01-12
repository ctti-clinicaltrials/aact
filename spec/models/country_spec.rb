require 'rails_helper'

RSpec.describe Country do

  describe 'Country#mapper' do
    it 'when contact location countries exist and removed country exist' do
      expected_data = [
        { 
          nct_id: 'NCT02552212', 
          name: 'United States', 
          removed: false
        },
        { 
          nct_id: 'NCT02552212', 
          name: 'Australia', 
          removed: false
        },
        { 
          nct_id: 'NCT02552212', 
          name: 'Bulgaria', 
          removed: false
        },
        { 
          nct_id: 'NCT02552212', 
          name: 'Canada', 
          removed: false
        },
        { 
          nct_id: 'NCT02552212', 
          name: 'Czechia', 
          removed: false
        },
        { 
          nct_id: 'NCT02552212', 
          name: 'Hungary', 
          removed: false
        },
        { 
          nct_id: 'NCT02552212', 
          name: 'Poland', 
          removed: false
        },
        { 
          nct_id: 'NCT02552212', 
          name: 'Russian Federation', 
          removed: false
        },
        { 
          nct_id: 'NCT02552212', 
          name: 'Taiwan', 
          removed: false
        },
        { 
          nct_id: 'NCT02552212', 
          name: 'Czech Republic', 
          removed: true
        }
      ]
      hash = JSON.parse(File.read('spec/support/json_data/NCT02278341.json'))
      processor = StudyJsonRecord::ProcessorV2.new(hash)
      expect(Country.mapper(processor)).to eq(expected_data)
    end

    it 'when contact location country exist and removed country does not exist' do
      expected_data = [
        { 
          nct_id: 'NCT04207047', 
          name: 'United States', 
          removed: false
        }
      ]  
      hash = JSON.parse(File.read('spec/support/json_data/NCT04207047.json'))
      processor = StudyJsonRecord::ProcessorV2.new(hash)
      expect(Country.mapper(processor)).to eq(expected_data)
    end    
  end  
  
end
