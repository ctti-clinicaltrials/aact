require 'rails_helper'

describe DetailedDescription do
  it "should create an instance of DetailedDescription" do
    # load the json
    content = JSON.parse(File.read('spec/support/json_data/detailed_description.json'))
    StudyJsonRecord.create(nct_id: "NCT000001", version: '2', content: content) # create a brand new json record

    # process the json
    StudyJsonRecord::Worker.new.process # import the new json record

    # load the database entries
    imported = DetailedDescription.all.map{|x| x.attributes }
    imported.each{|x| x.delete("id")}
    expect(imported).to eq([{ "nct_id" => "NCT000001", "description" => "Brief Study Summary..." }])
  end
end
