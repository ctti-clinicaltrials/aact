require 'rails_helper'

describe Milestone do
  it "should create an instance of Milestone", schema: :v2 do
    # load the json
    content = JSON.parse(File.read('spec/support/json_data/milestone.json'))
    StudyJsonRecord.create(nct_id: "NCT000001", version: '2', content: content) # create a brand new json record

    # process the json
    StudyJsonRecord::Worker.new.process # import the new json record

    # load the database entries
    result_group = ResultGroup.first
    imported = Milestone.all.map{|x| x.attributes }
    imported.each{|x| x.delete("id")}

    expected = [
      {
        "result_group_id" => result_group.id,
        "nct_id" => "NCT000001",
        "ctgov_group_code" => "FG000",
        "description" => "Participants 1",
        "title" => "STARTED",
        "period" => "Overall",
        "milestone_description" => "started comment",
        "count_units" => "10",
        "count" => 100
      },
      {
        "result_group_id" => result_group.id,
        "nct_id" => "NCT000001",
        "ctgov_group_code" => "FG000",
        "description" => "Participants 2",
        "title" => "STARTED",
        "period" => "Overall",
        "milestone_description" => "started comment",
        "count_units" => "10",
        "count" => 100
      },
      {
        "result_group_id" => result_group.id,
        "nct_id" => "NCT000001",
        "ctgov_group_code" => "FG000",
        "description" => "Participants 3",
        "title" => "MID",
        "period" => "Overall",
        "milestone_description" => "completed comment",
        "count_units" => "10",
        "count" => 100
      },
      {
        "result_group_id" => result_group.id,
        "nct_id" => "NCT000001",
        "ctgov_group_code" => "FG000",
        "description" => "Participants 4",
        "title" => "COMPLETE1",
        "period" => "Year 1",
        "milestone_description" => "started comment",
        "count_units" => "10",
        "count" => 100
      },
      {
        "result_group_id" => result_group.id,
        "nct_id" => "NCT000001",
        "ctgov_group_code" => "FG000",
        "description" => "Participants 5",
        "title" => "COMPLETE2",
        "period" => "Year 1",
        "milestone_description" => "completed comment",
        "count_units" => "10",
        "count" => 100
      },
    ]
    expect(imported).to eq(expected)
  end
end
