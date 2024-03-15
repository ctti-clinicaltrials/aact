require 'rails_helper'

describe 'DesignOutcome' do
  it 'should create an instance of DesignOutcome', schema: :v2 do
    expected_data = [
      {
        "nct_id" => "NCT000001",
        "outcome_type" => "otherOutcomes",
        "measure" => "Number of Participants With Erythema Score Based on Local Tolerability as Assessed by the Investigator at Day 1 (Post-application) and Weeks 2, 4, 8, and 14",
        "description" => "Erythema score was evaluated by the investigator on a 0 to 3 scale with a lower score indicating lesser severity.\n\nScore 0 (clear): no erythema present\n\nScore 1 (mild): slight erythema\n\nScore 2 (moderate): definite erythema\n\nScore 3 (severe): marked, fiery erythema",
        "population" => nil,
        "time_frame" => "Day 1 (Post-application) and Weeks 2, 4, 8, and 14"
      },
      {
        "nct_id" => "NCT000001",
        "outcome_type" => "otherOutcomes",
        "measure" => "Number of Participants With Erythema Score Based on Local Tolerability as Assessed by the Investigator at Week 12",
        "description" => "Erythema score was evaluated by the investigator on a 0 to 3 scale with a lower score indicating lesser severity.\n\nScore 0 (clear): no erythema present\n\nScore 1 (mild): slight erythema\n\nScore 2 (moderate): definite erythema\n\nScore 3 (severe): marked, fiery erythema",
        "population" => nil,
        "time_frame" => "Week 12"
      },
      {
        "nct_id" => "NCT000001",
        "outcome_type" => "primaryOutcomes",
        "measure" => "Change From Baseline in Total Lesion Count at Week 12",
        "description" => "Total lesion count was the sum of counts of the following lesion types (face only): Papule - raised inflammatory lesions, <0.5 cm in diameter with no visible purulent material; Pustule - raised inflammatory lesions, <0.5 cm in diameter with visible purulent material; Nodule - any circumscribed, inflammatory mass ≥0.5 cm in diameter.",
        "population" => nil,
        "time_frame" => "Baseline, Week 12"
      },
      {
        "nct_id" => "NCT000001",
        "outcome_type" => "secondaryOutcomes",
        "measure" => "abc",
        "description" => "Treatment responders were defined as participants who have either (1) 2 ordinal",
        "population" => nil,
        "time_frame" => "Baseline, Week 12"
      },
      {
        "nct_id" => "NCT000001",
        "outcome_type" => "secondaryOutcomes",
        "measure" => "def",
        "description" => "Papule - raised inflammatory lesions",
        "population" => nil,
        "time_frame" => "Baseline; Weeks 2, 4, 8, and 12"
      },
      {
        "nct_id" => "NCT000001",
        "outcome_type" => "secondaryOutcomes",
        "measure" => "ghi",
        "description" => "Pustule - raised inflammatory lesions",
        "population" => nil,
        "time_frame" => "Baseline; Weeks 2, 4, 8, and 12"
      }
    ]

    # Load the JSON
    content = JSON.parse(File.read('spec/support/json_data/design_outcome.json'))
    # Create a brand new JSON record
    StudyJsonRecord.create(nct_id: "NCT000001", version: '2', content: content)

    # Import the new JSON record
    StudyJsonRecord::Worker.new.process

    # Load the database entries
    imported = DesignOutcome.all.order(outcome_type: :asc, measure: :asc).map { |x| x.attributes }
    imported.each { |x| x.delete("id") }

    # Compare the modified imported data with the expected data
    expect(imported).to eq(expected_data)
  end
end

