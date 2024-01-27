require 'rails_helper'

RSpec.describe Sponsor do

  describe 'Sponsor#mapper' do
    it 'should return Lead and Collaborator sponsor types expected data' do
      expected_data = [
        { 
          nct_id: "NCT00763412", 
          agency_class: "INDIV", 
          lead_or_collaborator: "lead",
          name: "Arbelaez, Ana Maria"
        },
        { 
          nct_id: "NCT00763412", 
          agency_class: "OTHER", 
          lead_or_collaborator: "collaborator",
          name: "Washington University School of Medicine"
        },
        { 
          nct_id: "NCT00763412", 
          agency_class: "NIH", 
          lead_or_collaborator: "collaborator",
          name: "National Institutes of Health (NIH)"
        },
        { 
          nct_id: "NCT00763412", 
          agency_class: "INDUSTRY", 
          lead_or_collaborator: "collaborator",
          name: "Novo Nordisk A/S" 
        },
        { 
          nct_id: "NCT00763412", 
          agency_class: "NIH", 
          lead_or_collaborator: "collaborator",
          name: "National Institute of Diabetes and Digestive and Kidney Diseases (NIDDK)" 
        }
      ]  
      hash = JSON.parse(File.read('spec/support/json_data/NCT00763412.json'))
      processor = StudyJsonRecord::ProcessorV2.new(hash)
      expect(Sponsor.mapper(processor)).to eq(expected_data)
    end

    it 'should return Lead sponsor type expected data and no Collaborator sponsor type expected data' do
      expected_data = [
        { 
          nct_id: "NCT02552212", 
          agency_class: "INDUSTRY", 
          lead_or_collaborator: "lead",
          name: "UCB BIOSCIENCES GmbH"
        }
      ]
      hash = JSON.parse(File.read('spec/support/json_data/NCT02552212.json'))
      processor = StudyJsonRecord::ProcessorV2.new(hash)
      expect(Sponsor.mapper(processor)).to eq(expected_data)
    end
  end 

end