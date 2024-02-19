require 'rails_helper'

describe Condition do
  it "should create an instance of Condition" do
    expected_data = [
      {
        "nct_id" => "NCT000001",
        "name" => "Axial Spondyloarthritis",
        "downcase_name" => "axial spondyloarthritis"
      },
      {
        "nct_id" => "NCT000001",
        "name" => "Nonradiographic Axial Spondyloarthritis",
        "downcase_name" => "nonradiographic axial spondyloarthritis"
      },
      {
        "nct_id" => "NCT000001",
        "name" => "Nr-axSpA",
        "downcase_name" => "nr-axspa"
      }
    ]  

    # load the json
    content = JSON.parse(File.read('spec/support/json_data/condition.json'))
    StudyJsonRecord.create(nct_id: "NCT000001", version: '2', content: content) # create a brand new json record

    # process the json
    StudyJsonRecord::Worker.new.process # import the new json record

    # load the database entries
    imported = Condition.all.map{|x| x.attributes }
    imported.each{|x| x.delete("id")}
    expect(imported).to eq(expected_data)
  end
end

