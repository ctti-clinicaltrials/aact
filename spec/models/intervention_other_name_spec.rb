require 'rails_helper'

describe InterventionOtherName do
  it "should create an instance of InterventionOtherName", schema: :v2 do
    expected_data = [
      {
        "nct_id" => "NCT000001",
        "name" => "IFN alpha"
      },
      {
        "nct_id" => "NCT000001",
        "name" => "IFN-alpha-2b"
      },
      {
        "nct_id" => "NCT000001",
        "name" => "cisplatinum"
      },
      {
        "nct_id" => "NCT000001",
        "name" => "cis-diamminedichloroplatinum(II) (CDDP)"
      },
      {
        "nct_id" => "NCT000001",
        "name" => "5-FU"
      }
    ]  

    # load the json
    content = JSON.parse(File.read('spec/support/json_data/intervention_other_name.json'))
    StudyJsonRecord.create(nct_id: "NCT000001", version: '2', content: content) # create a brand new json record

    # process the json
    StudyJsonRecord::Worker.new.process # import the new json record

    # load the database entries
    imported = InterventionOtherName.all.map{ |x| x.attributes.except("id", "intervention_id") }

    # Compare the modified imported data with the expected data
    expect(imported).to eq(expected_data)
  end
end