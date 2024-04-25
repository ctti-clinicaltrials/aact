require 'rails_helper'

describe DesignGroupIntervention do
  it "should create an instance of DesignGroupIntervention", schema: :v2 do
    # load the json
    content = JSON.parse(File.read('spec/support/json_data/design_group_intervention.json'))
    StudyJsonRecord.create(nct_id: "NCT000001", version: '2', content: content) # create a brand new json record

    # process the json
    StudyJsonRecord::Worker.new.process # import the new json record

    # load the database entries
    imported = DesignGroupIntervention.all.map do |x|
      {
        "nct_id" => x.nct_id,
        "design_group" => x.design_group.title,
        "intervention" => x.intervention.name
      }
    end

    expected_data = [
      {
        "nct_id" => "NCT000001",
        "design_group" => "Arm 1",
        "intervention" => "Intervention 1"
      }
    ]
    expect(imported).to eq(expected_data)
  end
end
