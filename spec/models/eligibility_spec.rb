require 'rails_helper'

describe Eligibility do
  it "should create an instance of Eligibility" do
    expected_data = [
      {
        "nct_id" => "NCT000001",
        "sampling_method" => "NON_PROBABILITY_SAMPLE",
        "population" => "The exposed study population consists of pregnant...",
        "maximum_age" => "50 Years",
        "minimum_age" => "18 Years",
        "gender" => "FEMALE",
        "gender_based" => true,
        "gender_description" => "Persons assigned gender female at birth.",
        "healthy_volunteers" => false,
        "criteria" => "Inclusion Criteria:\n\n* Pregnant or recently pregnant...",
        "adult" => true,
        "child" => true,
        "older_adult" => true
      }
    ]

    # load the json
    content = JSON.parse(File.read('spec/support/json_data/eligibility.json'))
    StudyJsonRecord.create(nct_id: "NCT000001", version: '2', content: content) # create a brand new json record

    # process the json
    StudyJsonRecord::Worker.new.process # import the new json record

    # load the database entries
    imported = Eligibility.all.map { |x| x.attributes }
    imported.each { |x| x.delete("id") }

    # Expectations
    expect(imported).to eq(expected_data)
  end
end