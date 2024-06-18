require 'rails_helper'

describe ParticipantFlow do
  it "should create an instance of DetailedDescription", schema: :v2 do
    expected_data = [
      {
        "nct_id" => "NCT000001",
        "pre_assignment_details" => "Participants were randomized...",
        "recruitment_details" => "Upon achieving sufficient microbial...",
        "units_analyzed" => "Sites"
      }
    ]
    # load the json
    content = JSON.parse(File.read('spec/support/json_data/participant_flow.json'))
    StudyJsonRecord.create(nct_id: "NCT000001", version: '2', content: content) # create a brand new json record

    # process the json
    StudyJsonRecord::Worker.new.process # import the new json record

    # load the database entries
    imported = ParticipantFlow.all.map{|x| x.attributes }
    imported.each{|x| x.delete("id")}
    expect(imported).to eq(expected_data)
  end
end
