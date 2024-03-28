require 'rails_helper'

describe IpdInformationType do
  it "should create an instance of Document", schema: :v2 do
    expected_data = [
      {
        "nct_id" => "NCT000001",
        "name" => "STUDY_PROTOCOL"
      },
      {
        "nct_id" => "NCT000001",
        "name" => "SAP"
      },
      {
        "nct_id" => "NCT000001",
        "name" => "ICF"
      }
    ]  

    # load the json
    content = JSON.parse(File.read('spec/support/json_data/ipd_information_type.json'))
    StudyJsonRecord.create(nct_id: "NCT000001", version: '2', content: content) # create a brand new json record

    # process the json
    StudyJsonRecord::Worker.new.process # import the new json record

    # load the database entries
    imported = IpdInformationType.all.map{|x| x.attributes }
    imported.each{|x| x.delete("id")}

    # Compare the modified imported data with the expected data
    expect(imported).to eq(expected_data)
  end
end
