require 'rails_helper'

describe ResultGroup do
  it "should create an instance of ResultGroup", schema: :v2 do
    # load the json
    content = JSON.parse(File.read('spec/support/json_data/result_group.json'))
    StudyJsonRecord.create(nct_id: "NCT000001", version: '2', content: content) # create a brand new json record

    # process the json
    StudyJsonRecord::Worker.new.process # import the new json record

    # load the database entries
    imported = ResultGroup.all.map{|x| x.attributes }
    imported.each{|x| x.delete("id")}

    expected = [
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
