require 'rails_helper'

describe Link do
  it "should create an instance of Link" do
    expected_data = [
      {
        "nct_id" => "NCT000001",
        "url" => "http://www.fda.gov/Safety/MedWatch/SafetyInformation/default.htm",
        "description" => "FDA Safety Alerts and Recalls"
      }
    ]  

    # load the json
    content = JSON.parse(File.read('spec/support/json_data/link.json'))
    StudyJsonRecord.create(nct_id: "NCT000001", version: '2', content: content) # create a brand new json record

    # process the json
    StudyJsonRecord::Worker.new.process # import the new json record

    # load the database entries
    imported = Link.all.map{|x| x.attributes }
    imported.each{|x| x.delete("id")}
    expect(imported).to eq(expected_data)
  end
end