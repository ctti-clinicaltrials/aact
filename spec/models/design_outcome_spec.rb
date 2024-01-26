require 'rails_helper'

RSpec.describe DesignOutcome do

  describe 'DesignOutcome#mapper' do
    it 'should return primary, secondary, and other design outcomes data' do
      expected_data = [
        { 
          nct_id: "NCT03064438", 
          outcome_type: "primaryoutcomes", 
          measure: "Change From Baseline in Total Lesion Count at Week 12",
          time_frame: "Baseline, Week 12", 
          population: nil, 
          description: "Total lesion count was the sum of counts of the following lesion types (face only): Papule - raised inflammatory lesions, \\<0.5 cm in diameter with no visible purulent material; Pustule - raised inflammatory lesions, \\<0.5 cm in diameter with visible purulent material; Nodule - any circumscribed, inflammatory mass ≥0.5 cm in diameter."
        },
        { 
          nct_id: "NCT03064438", 
          outcome_type: "secondaryoutcomes", 
          measure: "Percent Change From Baseline in Investigator's Global Assessment (IGA) Score at Weeks 2, 4, 8, and 12",
          time_frame: "Baseline; Weeks 2, 4, 8, and 12", 
          population: nil, 
          description: "The IGA score is an ordered categorical value ranging from 0 (clear) to 4 (severe). A lower score indicated improvement in the condition.\n\nScore 0 (clear): no papules or pustules, no nodules, none or barely perceptible erythema\n\nScore 1 (near clear): very few (≤3) papules and/or pustules, no nodules, very mild erythema\n\nScore 2 (mild): few papules and pustules present, no nodules, mild erythema\n\nScore 3 (moderate): several papules and pustules are the predominant features, ≤2 nodules may be present, moderate erythema\n\nScore 4 (severe): numerous papules and pustules, multiple nodules may be present, severe erythema"
        },
        { 
          nct_id: "NCT03064438", 
          outcome_type: "secondaryoutcomes", 
          measure: "Percentage of Participants Who Were Treatment Responders at Week 12",
          time_frame: "Baseline, Week 12", 
          population: nil, 
          description: "Treatment responders were defined as participants who have either (1) 2 ordinal or more reductions in the IGA score from baseline or (2) an IGA score of 0 or 1.\n\nThe IGA score is an ordered categorical value ranging from 0 (clear) to 4 (severe). A lower score indicated improvement in the condition.\n\nScore 0 (clear): no papules or pustules, no nodules, none or barely perceptible erythema\n\nScore 1 (near clear): very few (≤3) papules and/or pustules, no nodules, very mild erythema\n\nScore 2 (mild): few papules and pustules present, no nodules, mild erythema\n\nScore 3 (moderate): several papules and pustules are the predominant features, ≤2 nodules may be present, moderate erythema\n\nScore 4 (severe): numerous papules and pustules, multiple nodules may be present, severe erythema"
        },
        { 
          nct_id: "NCT03064438", 
          outcome_type: "secondaryoutcomes", 
          measure: "Change From Baseline in Papule Lesions at Weeks 2, 4, 8, and 12",
          time_frame: "Baseline; Weeks 2, 4, 8, and 12", 
          population: nil, 
          description: "Papule - raised inflammatory lesions, \\<0.5 cm in diameter with no visible purulent material"
        },
        { 
          nct_id: "NCT03064438", 
          outcome_type: "secondaryoutcomes", 
          measure: "Change From Baseline in Pustule Lesions at Weeks 2, 4, 8, and 12",
          time_frame: "Baseline; Weeks 2, 4, 8, and 12", 
          population: nil, 
          description: "Pustule - raised inflammatory lesions, \\<0.5 cm in diameter with visible purulent material"
        },
        { 
          nct_id: "NCT03064438", 
          outcome_type: "secondaryoutcomes", 
          measure: "Change From Baseline in Nodule Lesions at Weeks 2, 4, 8, and 12",
          time_frame: "Baseline; Weeks 2, 4, 8, and 12", 
          population: nil, 
          description: "Nodule - any circumscribed, inflammatory mass ≥0.5 cm in diameter"
        },
        { 
          nct_id: "NCT03064438", 
          outcome_type: "secondaryoutcomes", 
          measure: "Change From Baseline in Papules + Pustules Lesions at Weeks 2, 4, 8, and 12",
          time_frame: "Baseline; Weeks 2, 4, 8, and 12", 
          population: nil, 
          description: "Papules + pustules lesions were the sum of counts of papule (raised inflammatory lesions, \\<0.5 cm in diameter with no visible purulent material) and pustule (raised inflammatory lesions, \\<0.5 cm in diameter with visible purulent material) lesions."
        },
        { 
          nct_id: "NCT03064438", 
          outcome_type: "secondaryoutcomes", 
          measure: "Number of Participants With Adverse Events",
          time_frame: "Baseline to Week 14", 
          population: nil, 
          description: "Number of participants reporting any adverse event including local tolerability of signs and symptoms of irritation, clinical laboratory safety tests, and vital signs."
        },
        { 
          nct_id: "NCT03064438", 
          outcome_type: "otheroutcomes", 
          measure: "Number of Participants With Erythema Score Based on Local Tolerability as Assessed by the Investigator at Week 12",
          time_frame: "Week 12", 
          population: nil, 
          description: "Erythema score was evaluated by the investigator on a 0 to 3 scale with a lower score indicating lesser severity.\n\nScore 0 (clear): no erythema present\n\nScore 1 (mild): slight erythema\n\nScore 2 (moderate): definite erythema\n\nScore 3 (severe): marked, fiery erythema"
        },
        { 
          nct_id: "NCT03064438", 
          outcome_type: "otheroutcomes", 
          measure: "Number of Participants With Erythema Score Based on Local Tolerability as Assessed by the Investigator at Day 1 (Post-application) and Weeks 2, 4, 8, and 14",
          time_frame: "Day 1 (Post-application) and Weeks 2, 4, 8, and 14", 
          population: nil, 
          description: "Erythema score was evaluated by the investigator on a 0 to 3 scale with a lower score indicating lesser severity.\n\nScore 0 (clear): no erythema present\n\nScore 1 (mild): slight erythema\n\nScore 2 (moderate): definite erythema\n\nScore 3 (severe): marked, fiery erythema"
        }
      ]
      hash = JSON.parse(File.read('spec/support/json_data/NCT03064438.json'))
      processor = StudyJsonRecord::ProcessorV2.new(hash)
      expect(DesignOutcome.mapper(processor)).to eq(expected_data)
    end
    
    it 'should return primary and secondary design outcomes data and no other design outcomes data' do
      expected_data = [
        { 
          nct_id: "NCT00763412", 
          outcome_type: "primaryoutcomes", 
          measure: "BMI",
          time_frame: "2 year/end of study", 
          population: nil,
          description: nil
        },
        { 
          nct_id: "NCT00763412", 
          outcome_type: "primaryoutcomes", 
          measure: "Body Composition",
          time_frame: "2 year/end of study", 
          population: nil, 
          description: "Reporting % of Fat and Lean body mass"
        },
        { 
          nct_id: "NCT00763412", 
          outcome_type: "primaryoutcomes", 
          measure: "CRP",
          time_frame: "2 year/end of study", 
          population: nil, 
          description: nil
        },
        { 
          nct_id: "NCT00763412", 
          outcome_type: "secondaryoutcomes", 
          measure: "Glucose Tolerance",
          time_frame: "2-year", 
          population: nil,
          description: "We completed the OGTT at the 2 year/end of study visit."
        },
        { 
          nct_id: "NCT00763412", 
          outcome_type: "secondaryoutcomes", 
          measure: "Inflammatory Markers",
          time_frame: "2 year/end of study", 
          population: nil,
          description: nil
        },
        { 
          nct_id: "NCT00763412", 
          outcome_type: "secondaryoutcomes", 
          measure: "Wt Z Score",
          time_frame: "2 year/end of study", 
          population: nil, 
          description: nil
        },
        { 
          nct_id: "NCT00763412", 
          outcome_type: "secondaryoutcomes", 
          measure: "Tanner Stage",
          time_frame: "2 year/end of study", 
          population: nil,
          description: "Puberty scale measuring 1-5, 1 being least development, 5 being most development."
        },
        { 
          nct_id: "NCT00763412", 
          outcome_type: "secondaryoutcomes", 
          measure: "FEV 1",
          time_frame: "2 year/end of study", 
          population: nil,
          description: "% of lung function"
        },
        { 
          nct_id: "NCT00763412", 
          outcome_type: "secondaryoutcomes", 
          measure: "C-Peptide",
          time_frame: "2 year", 
          population: nil, 
          description: nil
        }
      ]
      hash = JSON.parse(File.read('spec/support/json_data/NCT00763412.json'))
      processor = StudyJsonRecord::ProcessorV2.new(hash)
      expect(DesignOutcome.mapper(processor)).to eq(expected_data)  
    end

    it 'should return primary design outcomes data and no secondary or other design outcomes data' do
      expected_data = [
        { 
          nct_id: "NCT00973089", 
          outcome_type: "primaryoutcomes", 
          measure: "The success of the alternative treatment of the deep carious lesion.",
          time_frame: "Half annually for three years", 
          population: nil,
          description: nil
        }
      ]
      hash = JSON.parse(File.read('spec/support/json_data/NCT00973089.json'))
      processor = StudyJsonRecord::ProcessorV2.new(hash)
      expect(DesignOutcome.mapper(processor)).to eq(expected_data)
    end   

    it 'should return nil when design outcomes data is empty' do
      hash = JSON.parse(File.read('spec/support/json_data/design_outcome_empty.json'))
      processor = StudyJsonRecord::ProcessorV2.new(hash)
      expect(DesignOutcome.mapper(processor)).to eq(nil)  
    end
  end 

end