require 'rails_helper'

describe StudyReference do
  it "should create an instance of StudyReference", schema: :v2 do
    expected_data = [
      {
        "pmid" => "33178765",
        "reference_type" => "DERIVED",
        "citation" => "Zhao S, Fan N, Li H…",
        "retractions" => [
          {
            "pmid" => "32861403",
            "source" => "Br J Anaesth. 2020 Sep;125(3):412-413"
          }
        ]
      }
    ]

    # load the json
    content = JSON.parse(File.read('spec/support/json_data/study_reference.json'))
    StudyJsonRecord.create(nct_id: "NCT000001", version: '2', content: content) # create a brand new json record

    # process the json
    StudyJsonRecord::Worker.new.process # import the new json record

    # load the database entries
    imported = StudyReference.all.map { |x| x.attributes }
    imported.each { |x| x.delete("id") }
    
    # Compare the modified imported data with the expected data
    expect(imported).to eq(expected_data)   
  end
end