require 'rails_helper'

describe ResultContact do
  it "should create an instance of ResultContact" do
    expected_data = [
      {
        "nct_id" => "NCT000001",
        "name" => "UCB",
        "organization" => "Cares",
        "email" => "UCBCares@ucb.com",
        "phone" => "+1844 599",
        "extension" => "2273"
      }
    ]  

    # load the json
    content = JSON.parse(File.read('spec/support/json_data/result_contact.json'))
    StudyJsonRecord.create(nct_id: "NCT000001", version: '2', content: content) # create a brand new json record

    # process the json
    StudyJsonRecord::Worker.new.process # import the new json record

    # load the database entries
    imported = ResultContact.all.map{|x| x.attributes }
    imported.each{|x| x.delete("id")}
    expect(imported).to eq(expected_data)
  end
end
