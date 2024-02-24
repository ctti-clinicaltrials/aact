require 'rails_helper'

describe Intervention do
  it "should create an instance of Intervention", schema: :v2 do
    expected_data = [
      {
        "nct_id" => "NCT000001",
        "intervention_type" => "DEVICE",
        "name" => "WFMA - wireless floating microelectrode array",
        "description" => "Wirelessly transmitted patterns of electrical stimulation will be delivered to the visual cortex of study participants to generate visual percepts."
      }
    ]

    # load the json
    content = JSON.parse(File.read('spec/support/json_data/intervention.json'))
    StudyJsonRecord.create(nct_id: "NCT000001", version: '2', content: content) # create a brand new json record

    # process the json
    StudyJsonRecord::Worker.new.process # import the new json record

    # load the database entries
    imported = Intervention.all.map { |x| x.attributes }
    imported.each { |x| x.delete("id") }
    
    # Compare the modified imported data with the expected data
    expect(imported).to eq(expected_data)
  end
end