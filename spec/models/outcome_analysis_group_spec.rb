require 'rails_helper'

RSpec.describe OutcomeAnalysisGroup, type: :model do
  it "should create an instance of OutcomeAnalysisGroup", schema: :v2 do
    expected_data = [
      {
        "nct_id" => "NCT000001",
        "result_group_id" => nil,
        "ctgov_group_code" => "OG000"
      },
      {
        "nct_id" => "NCT000001",
        "result_group_id" => nil,
        "ctgov_group_code" => "OG001"
      },
      {
        "nct_id" => "NCT000001",
        "result_group_id" => nil,
        "ctgov_group_code" => "OG002"
      },
      {
        "nct_id" => "NCT000001",
        "result_group_id" => nil,
        "ctgov_group_code" => "OG003"
      },
      {
        "nct_id" => "NCT000001",
        "result_group_id" => nil,
        "ctgov_group_code" => "OG004"
      },
      {
        "nct_id" => "NCT000001",
        "result_group_id" => nil,
        "ctgov_group_code" => "OG005"
      },
      {
        "nct_id" => "NCT000001",
        "result_group_id" => nil,
        "ctgov_group_code" => "OG006"
      },
      {
        "nct_id" => "NCT000001",
        "result_group_id" => nil,
        "ctgov_group_code" => "OG007"
      },
      {
        "nct_id" => "NCT000001",
        "result_group_id" => nil,
        "ctgov_group_code" => "OG008"
      },
      {
        "nct_id" => "NCT000001",
        "result_group_id" => nil,
        "ctgov_group_code" => "OG009"
      },
      {
        "nct_id" => "NCT000001",
        "result_group_id" => nil,
        "ctgov_group_code" => "OG010"
      },
      {
        "nct_id" => "NCT000001",
        "result_group_id" => nil,
        "ctgov_group_code" => "OG011"
      },
      {
        "nct_id" => "NCT000001",
        "result_group_id" => nil,
        "ctgov_group_code" => "OG012"
      },
      {
        "nct_id" => "NCT000001",
        "result_group_id" => nil,
        "ctgov_group_code" => "OG013"
      }
    ]  

    # load the json
    content = JSON.parse(File.read('spec/support/json_data/outcome_analysis_group.json'))
    StudyJsonRecord.create(nct_id: "NCT000001", version: '2', content: content) # create a brand new json record

    # process the json
    StudyJsonRecord::Worker.new.process # import the new json record

    # load the database entries
    imported = OutcomeAnalysisGroup.all.map{ |x| x.attributes.except("id", "outcome_analysis_id") }
    
    # Compare the modified imported data with the expected data
    expect(imported).to eq(expected_data)
  end
end
