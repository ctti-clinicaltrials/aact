require 'rails_helper'

describe ResultAgreement do
  it "should create an instance of ResultAgreement", schema: :v2 do
    expected_data = [
      {
        "agreement" => nil,
        "nct_id" => "NCT000001",
        "pi_employee" => false,
        "restriction_type" => "OTHER",
        "restrictive_agreement" => true,
        "other_details" => "Institute and/or Principal Investigator may publish trial data..."
      }
    ]

    # Load the JSON data
    content = JSON.parse(File.read('spec/support/json_data/result_agreement.json'))
    StudyJsonRecord.create(nct_id: "NCT000001", version: '2', content: content) # Create a new json record

    # Process the JSON data to import it into the database
    StudyJsonRecord::Worker.new.process

    # Load the database entries
    imported = ResultAgreement.all.map { |x| x.attributes }
    imported.each { |x| x.delete("id") }
    
    # Compare the modified imported data with the expected data
    expect(imported).to eq(expected_data)   
  end
end
