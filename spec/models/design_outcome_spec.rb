require 'rails_helper'

RSpec.describe DesignOutcome do
  describe 'DesignOutcome#mapper' do
    it 'study should have expected design_outcomes_data info' do
      expected_data = [
        { 
          nct_id: 'NCT03064438', 
          outcome_type: 'primaryOutcomes', 
          measure: 'Change From Baseline in Total Lesion Count at Week 12',
          time_frame: 'Baseline, Week 12', 
          population: false, 
          description: 'Total lesion count was the sum of counts of the following lesion types (face only): Papule - raised inflammatory lesions, \\<0.5 cm in diameter with no visible purulent material; Pustule - raised inflammatory lesions, \\<0.5 cm in diameter with visible purulent material; Nodule - any circumscribed, inflammatory mass ≥0.5 cm in diameter.'
        },
        { 
          nct_id: 'NCT03064438', 
          outcome_type: 'secondaryOutcomes', 
          measure: "Percent Change From Baseline in Investigator's Global Assessment (IGA) Score at Weeks 2, 4, 8, and 12",
          time_frame: 'Baseline; Weeks 2, 4, 8, and 12', 
          population: false, 
          description: 'The IGA score is an ordered categorical value ranging from 0 (clear) to 4 (severe). A lower score indicated improvement in the condition.\n\nScore 0 (clear): no papules or pustules, no nodules, none or barely perceptible erythema\n\nScore 1 (near clear): very few (≤3) papules and/or pustules, no nodules, very mild erythema\n\nScore 2 (mild): few papules and pustules present, no nodules, mild erythema\n\nScore 3 (moderate): several papules and pustules are the predominant features, ≤2 nodules may be present, moderate erythema\n\nScore 4 (severe): numerous papules and pustules, multiple nodules may be present, severe erythema'
        }
      ]
      hash = JSON.parse(File.read('spec/support/json_data/NCT03064438.json'))
      processor = StudyJsonRecord::ProcessorV2.new(hash)
      expect(DesignOutcome.mapper(processor)).to eq(expected_data)
    end
  end  
end