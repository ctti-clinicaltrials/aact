require 'rails_helper'

describe BriefSummary do
  it "should create an instance of BriefSummary", schema: :v2 do
    # load the json
    content = JSON.parse(File.read('spec/support/json_data/brief_summary.json'))
    StudyJsonRecord.create(nct_id: "NCT000001", version: '2', content: content) # create a brand new json record

    # process the json
    StudyJsonRecord::Worker.new.process # import the new json record

    # load the database entries
    imported = BriefSummary.all.map{|x| x.attributes }
    imported.each{|x| x.delete("id")}
    expect(imported).to eq([{ "nct_id" => "NCT000001", "description" => "Brief Study Summary..." }])
  end
end
