require 'rails_helper'

RSpec.describe CentralContact, type: :model do
  it "should create an instance of CentralContact", schema: :v2 do
    expected_data = [
      {
        "nct_id" => "NCT000001",
        "contact_type" => "primary",
        "name" => "Meldon Kahan, MDCCFP FRCPC",
        "phone" => "416-323-6400",
        "email" => 'meldon.kahan@wchospital.ca',
        "phone_extension" => "7511",
        "role" => "CONTACT"
      },
      {
        "nct_id" => "NCT000001",
        "contact_type" => "backup",
        "name" => "Kate Hardy, MSW RSW",
        "phone" => "416-323-6400",
        "email" => 'kate.hardy@wchospital.ca',
        "phone_extension" => "7511",
        "role" => "CONTACT"
      }
    ]

    # load the json
    content = JSON.parse(File.read('spec/support/json_data/central_contact.json'))
    StudyJsonRecord.create(nct_id: "NCT000001", version: '2', content: content) # create a brand new json record

    # process the json
    StudyJsonRecord::Worker.new.process # import the new json record

    # load the database entries
    imported = CentralContact.all.map{|x| x.attributes }
    imported.each{|x| x.delete("id")}
    expect(imported).to eq(expected_data)
  end
end