require 'rails_helper'

describe Design do
  it "should create an instance of Design" do
    expected_data = [
      {
        "nct_id" => "NCT000001",
        "allocation" => "RANDOMIZED",
        "intervention_model" => "CROSSOVER",
        "intervention_model_description" => "After the eligibility of a subject has been determined in an initial...",
        "observational_model" => 'COHORT',
        "primary_purpose" => "BASIC_SCIENCE",
        "masking" => "QUADRUPLE",
        "masking_description" => "The study will be double-blinded...",
        "time_perspective" => 'PROSPECTIVE',
        "subject_masked" => true,
        "caregiver_masked" => true,
        "investigator_masked" => true,
        "outcomes_assessor_masked" => false
      }
    ]

    # load the json
    content = JSON.parse(File.read('spec/support/json_data/design.json'))
    StudyJsonRecord.create(nct_id: "NCT000001", version: '2', content: content) # create a brand new json record

    # process the json
    StudyJsonRecord::Worker.new.process # import the new json record

    # load the database entries
    imported = Design.all.map { |x| x.attributes }
    imported.each { |x| x.delete("id") }
    
    # Remove the masking, masking_description, and intervention_model_description attributes
    # expected_data.each { |data| data.delete("masking"); data.delete("masking_description"); data.delete("intervention_model_description") }
    # imported.each { |data| data.delete("masking"); data.delete("masking_description"); data.delete("intervention_model_description") }

    # Compare the modified imported data with the expected data
    expect(imported).to eq(expected_data)   
  end
end