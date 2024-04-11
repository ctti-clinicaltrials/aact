require 'rails_helper'

describe Retraction do
  it "should create an instance of Retraction", schema: :v2 do
    expected_data = [
      {
        "nct_id" => "NCT000001",
        "pmid" => "32861403",
        "source" => "Br J Anaesth. 2020 Sep;125(3):412-413"
      }
    ]

    # load the json
    content = JSON.parse(File.read('spec/support/json_data/study_reference.json'))
    StudyJsonRecord.create(nct_id: "NCT000001", version: '2', content: content) # create a brand new json record

    # process the json
    StudyJsonRecord::Worker.new.process # import the new json record

    # load the database entries
    imported = Retraction.all.map { |x| x.attributes }
    
    # Delete the 'id' and 'reference_id' attributes from each element in the imported data
    imported.each { |x| x.delete('id'); x.delete('reference_id') }

    # Compare the modified imported data with the expected data
    expect(imported).to eq(expected_data)   
  end
end
