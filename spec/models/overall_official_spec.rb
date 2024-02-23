require 'rails_helper'

describe OverallOfficial do

  it 'should create an instance of OverallOfficial', schema: :v2 do
    expected_data = [
      { 
        "nct_id" => "NCT000001", 
        "name" => "Imanol Otaegui, MD", 
        "affiliation" => "Hospital Universitari Vall d'hebron Barcelona, Spain", 
        "role" => "PRINCIPAL_INVESTIGATOR"
      }
    ]
       
    # load the json
    content = JSON.parse(File.read('spec/support/json_data/overall_official.json'))
    StudyJsonRecord.create(nct_id: "NCT000001", version: '2', content: content) # create a brand new json record

    # process the json
    StudyJsonRecord::Worker.new.process # import the new json record

    # load the database entries
    imported = OverallOfficial.all.map { |x| x.attributes }
    imported.each { |x| x.delete("id") }
    
    # Compare the modified imported data with the expected data
    expect(imported).to eq(expected_data)
  end 
   
end  