require 'rails_helper'

describe FacilityContact do
  it "should create instances of FacilityContact", schema: :v2 do
    expected_data = [
      {
        "nct_id" => "NCT000001",
        "contact_type" => "primary",
        "name" => "Daniela Pasero, MD",
        "email" => "daniela.pasero@unito.it",
        "phone" => "+39 011 633",
        "phone_extension" => "6129"
      },
      {
        "nct_id" => "NCT000001",
        "contact_type" => "backup",
        "name" => "Luana Bonaccurso",
        "email" => "223776@edu.unito.it",
        "phone" => "+39 011 633",
        "phone_extension" => "6129"
      }
    ]
    

    # Load the JSON
    content = JSON.parse(File.read('spec/support/json_data/facility_contact.json'))

    # Create a new StudyJsonRecord with the provided content
    StudyJsonRecord.create(nct_id: "NCT000001", version: '2', content: content)

    # Process the JSON
    StudyJsonRecord::Worker.new.process

    # Load the database entries
    imported = FacilityContact.all.map { |x| x.attributes }
    imported.each { |x| x.delete('id'); x.delete('facility_id') }

    # Compare the modified imported data with the expected data
    expect(imported).to eq(expected_data)   
  end
end
