require 'rails_helper'

RSpec.describe OutcomeCount, type: :model do
  it "should create an instance of OutcomeCount", schema: :v2 do
    expected_data = [
      {
        "nct_id" => "NCT000001",
        "ctgov_group_code" => "OG000",
        "scope" => "Measure",
        "units" => "Participants",
        "count" => 120
      },
      {
        "nct_id" => "NCT000001",
        "ctgov_group_code" => "OG000",
        "scope" => "Measure",
        "units" => "Participants",
        "count" => 158
      },
      {
        "nct_id" => "NCT000001",
        "ctgov_group_code" => "OG001",
        "scope" => "Measure",
        "units" => "Participants",
        "count" => 159
      },
      {
        "nct_id" => "NCT000001",
        "ctgov_group_code" => "OG002",
        "scope" => "Measure",
        "units" => "Participants",
        "count" => 96
      },
      {
        "nct_id" => "NCT000001",
        "ctgov_group_code" => "OG003",
        "scope" => "Measure",
        "units" => "Participants",
        "count" => 20
      },
      {
        "nct_id" => "NCT000001",
        "ctgov_group_code" => "OG004",
        "scope" => "Measure",
        "units" => "Participants",
        "count" => 243
      }
    ]

    # load the json
    content = JSON.parse(File.read('spec/support/json_data/outcome_count.json'))
    StudyJsonRecord.create(nct_id: "NCT000001", version: '2', content: content) # create a brand new json record

    # process the json
    StudyJsonRecord::Worker.new.process # import the new json record

    # load the database entries
    imported = OutcomeCount.all.map { |x| x.attributes.except("id", "outcome_id", "result_group_id") }
  
    # Compare the modified imported data with the expected data
    expect(imported).to eq(expected_data)
  end
end