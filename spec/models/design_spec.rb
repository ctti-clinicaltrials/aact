require 'rails_helper'

describe Design do
  it "should create an instance of Design" do
    expected_data = [
      {
        "nct_id" => "NCT000001",
        "allocation" => "{\"designInfo\"=>{\"allocation\"=>\"RANDOMIZED\", \"maskingInfo\"=>{\"masking\"=>\"QUADRUPLE\", \"whoMasked\"=>[\"PARTICIPANT\", \"CARE_PROVIDER\", \"INVESTIGATOR\", \"OUTCOMES_ASSESSOR\"], \"maskingDescription\"=>\"The study will be double-blinded...\"}, \"primaryPurpose\"=>\"BASIC_SCIENCE\", \"interventionModel\"=>\"CROSSOVER\", \"interventionModelDescription\"=>\"After the eligibility of a subject has been determined in an initial...\"}}",
        "caregiver_masked" => true,
        "intervention_model" => "{\"designInfo\"=>{\"allocation\"=>\"RANDOMIZED\", \"maskingInfo\"=>{\"masking\"=>\"QUADRUPLE\", \"whoMasked\"=>[\"PARTICIPANT\", \"CARE_PROVIDER\", \"INVESTIGATOR\", \"OUTCOMES_ASSESSOR\"], \"maskingDescription\"=>\"The study will be double-blinded...\"}, \"primaryPurpose\"=>\"BASIC_SCIENCE\", \"interventionModel\"=>\"CROSSOVER\", \"interventionModelDescription\"=>\"After the eligibility of a subject has been determined in an initial...\"}}",
        "intervention_model_description" => "{\"designInfo\"=>{\"allocation\"=>\"RANDOMIZED\", \"maskingInfo\"=>{\"masking\"=>\"QUADRUPLE\", \"whoMasked\"=>[\"PARTICIPANT\", \"CARE_PROVIDER\", \"INVESTIGATOR\", \"OUTCOMES_ASSESSOR\"], \"maskingDescription\"=>\"The study will be double-blinded...\"}, \"primaryPurpose\"=>\"BASIC_SCIENCE\", \"interventionModel\"=>\"CROSSOVER\", \"interventionModelDescription\"=>\"After the eligibility of a subject has been determined in an initial...\"}}",
        "investigator_masked" => true,
        "masking" => "{\"designInfo\"=>{\"allocation\"=>\"RANDOMIZED\", \"maskingInfo\"=>{\"masking\"=>\"QUADRUPLE\", \"whoMasked\"=>[\"PARTICIPANT\", \"CARE_PROVIDER\", \"INVESTIGATOR\", \"OUTCOMES_ASSESSOR\"], \"maskingDescription\"=>\"The study will be double-blinded...\"}, \"primaryPurpose\"=>\"BASIC_SCIENCE\", \"interventionModel\"=>\"CROSSOVER\", \"interventionModelDescription\"=>\"After the eligibility of a subject has been determined in an initial...\"}}",
        "masking_description" => "{\"designInfo\"=>{\"allocation\"=>\"RANDOMIZED\", \"maskingInfo\"=>{\"masking\"=>\"QUADRUPLE\", \"whoMasked\"=>[\"PARTICIPANT\", \"CARE_PROVIDER\", \"INVESTIGATOR\", \"OUTCOMES_ASSESSOR\"], \"maskingDescription\"=>\"The study will be double-blinded...\"}, \"primaryPurpose\"=>\"BASIC_SCIENCE\", \"interventionModel\"=>\"CROSSOVER\", \"interventionModelDescription\"=>\"After the eligibility of a subject has been determined in an initial...\"}}",
        "observational_model" => nil,
        "outcomes_assessor_masked" => true,
        "primary_purpose" => "{\"designInfo\"=>{\"allocation\"=>\"RANDOMIZED\", \"maskingInfo\"=>{\"masking\"=>\"QUADRUPLE\", \"whoMasked\"=>[\"PARTICIPANT\", \"CARE_PROVIDER\", \"INVESTIGATOR\", \"OUTCOMES_ASSESSOR\"], \"maskingDescription\"=>\"The study will be double-blinded...\"}, \"primaryPurpose\"=>\"BASIC_SCIENCE\", \"interventionModel\"=>\"CROSSOVER\", \"interventionModelDescription\"=>\"After the eligibility of a subject has been determined in an initial...\"}}",
        "subject_masked" => true,
        "time_perspective" => nil
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
    expect(imported).to eq(expected_data)   
  end
end