require 'rails_helper'

describe OutcomeMeasurement do
  it "should create an instance of OutcomeMeasurement", schema: :v2 do
    expected_data = [
    ]
    # load the json
    content = JSON.parse(File.read('spec/support/json_data/outcome_measurement.json'))
    StudyJsonRecord.create(nct_id: "NCT000001", version: '2', content: content) # create a brand new json record

    # process the json
    StudyJsonRecord::Worker.new.process # import the new json record

    # load the database entries
    imported = OutcomeMeasure.all.map do |x|
      {
      }
    end
  
    # Compare the modified imported data with the expected data
    expect(imported).to eq(expected_data)
  end
end
