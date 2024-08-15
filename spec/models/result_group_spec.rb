require 'rails_helper'

describe ResultGroup do
  it "should create an instance of ResultGroup", schema: :v2 do
    # load the json
    content = JSON.parse(File.read('spec/support/json_data/result_group.json'))
    StudyJsonRecord.create(nct_id: "NCT000001", version: '2', content: content) # create a brand new json record

    # process the json
    StudyJsonRecord::Worker.new.process_study("NCT000001")

    # load the database entries
    imported = ResultGroup.all.map { |x| x.attributes.except('id', 'outcome_id') }

    # order of expected depends on order of importing different types of result groups
    expected = [
      {
        "nct_id"=>"NCT000001",
        "result_type"=>"Outcome",
        "ctgov_group_code" => "OG0000",
        "title" => "Outcome 1",
        "description" => "Outcome Group 1 description"
      },
      {
        "nct_id"=>"NCT000001",
        "result_type"=>"Outcome",
        "ctgov_group_code" => "OG0001",
        "title" => "Outcome 2",
        "description" => "Outcome Group 2 description"
      },
      {
        "nct_id"=>"NCT000001",
        "result_type"=>"Outcome",
        "ctgov_group_code" => "OG0000",
        "title" => "Outcome 3",
        "description" => "Outcome Group 3 description"
      },
      {
        "nct_id"=>"NCT000001",
        "result_type"=>"Participant Flow",
        "ctgov_group_code"=>"FG000",
        "title"=>"Cohort 1",
        "description"=>"Cohort 1 received..."
      },
      {
        "nct_id"=>"NCT000001",
        "result_type"=>"Participant Flow",
        "ctgov_group_code"=>"FG001",
        "title"=>"Cohort 2",
        "description"=>"Cohort 2 received..."
      }
    ]
    
    expect(imported).to eq(expected)
  end
end
