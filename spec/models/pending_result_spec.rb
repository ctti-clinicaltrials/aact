require 'rails_helper'

describe PendingResult do

  it 'should create an instance of PendingResult', schema: :v2 do
    expected_data = [
      { 
        "nct_id" => "NCT000001", 
        "event" => "RELEASE", 
        "event_date_description" => "2022-12-23", 
        "event_date" => Date.parse("Fri, 23 Dec 2022")
      },
      { 
        "nct_id" => "NCT000001", 
        "event" => "RESET", 
        "event_date_description" => "2023-10-20", 
        "event_date" => Date.parse("Fri, 20 Oct 2023")
      },
      { 
        "nct_id" => "NCT000001", 
        "event" => "UNRELEASE", 
        "event_date_description" => "2024-08-24", 
        "event_date" => Date.parse("Sat, 24 Aug 2024")
      }
    ]
       
    # load the json
    content = JSON.parse(File.read('spec/support/json_data/pending_result.json'))
    StudyJsonRecord.create(nct_id: "NCT000001", version: '2', content: content) # create a brand new json record

    # process the json
    StudyJsonRecord::Worker.new.process # import the new json record

    # load the database entries
    imported = PendingResult.all.map { |x| x.attributes }
    imported.each { |x| x.delete("id") }
    
    # Compare the modified imported data with the expected data
    expect(imported).to eq(expected_data)
  end

end
