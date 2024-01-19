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


    # it 'should return expected Lead sponsor type data' do
    #   expected_data = [
    #     { 
    #       nct_id: "NCT00763412", 
    #       agency_class: "INDIV", 
    #       lead_or_collaborator: "lead",
    #       name: "Arbelaez, Ana Maria"
    #     }
    #   ]
    #   hash = JSON.parse(File.read('spec/support/json_data/NCT00763412.json'))
    #   processor = StudyJsonRecord::ProcessorV2.new(hash)
    #   expect(Sponsor.mapper(processor)).to eq(expected_data)
    # end

    # it 'should return expected Collaborator sponsor type data' do
    #   expected_data = [
    #     { 
    #       nct_id: "NCT00763412", 
    #       agency_class: "INDIV", 
    #       lead_or_collaborator: "lead",
    #       name: "Arbelaez, Ana Maria"
    #     },
    #     { 
    #       nct_id: "NCT00763412", 
    #       agency_class: "INDIV", 
    #       lead_or_collaborator: "lead",
    #       name: "Arbelaez, Ana Maria"
    #     },
    #     { 
    #       nct_id: "NCT03064438", 
    #       outcome_type: "secondaryoutcomes", 
    #       measure: "Percentage of Participants Who Were Treatment Responders at Week 12",
    #       time_frame: "Baseline, Week 12", 
    #       population: nil, 
    #       }
    #   ]

    # it 'should return nil when  data is empty' do
    #   hash = JSON.parse(File.read('spec/support/json_data/design_outcome_empty.json'))
    #   processor = StudyJsonRecord::ProcessorV2.new(hash)
    #   expect(DesignOutcome.mapper(processor)).to eq(nil)  
    # end

  end  
end