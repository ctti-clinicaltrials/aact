require 'rails_helper'

RSpec.describe Facility, type: :model do
    # Associations
  
    # Custom Mapping
    describe 'custom mapping' do

      it 'correctly maps fields from a structured input', schema: :v2 do
        content = JSON.parse(File.read('spec/support/json_data/facility.json'))
        StudyJsonRecord.create(nct_id: "NCT000001", version: '2', content: content) # Create a brand new json record
  
        StudyJsonRecord::Worker.new.process
        imported = Facility.all.map { |x| x.attributes.except("id", "created_at", "updated_at") }


        expected = [
            {
            "nct_id"=>"NCT000001",
            "status" => "Active",
            "name" => "Test Facility",
            "city" => "Test City",
            "state" => "Test State",
            "zip" => "12345",
            "country" => "Test Country",
            "latitude" => -12.97111,
            "longitude" => -38.51083
            }
        ]

        expect(imported).to match_array(expected)

      end

      it 'correctly maps and creates associated investigators and contacts from structured input', schema: :v2 do
        content = JSON.parse(File.read('spec/support/json_data/facility.json'))
        StudyJsonRecord.create(nct_id: "NCT000001", version: '2', content: content)
      
        StudyJsonRecord::Worker.new.process
      
        facility = Facility.last
      
        # Test for FacilityInvestigators creation and attributes
        expect(facility.facility_investigators.size).to eq(1)
        investigator = facility.facility_investigators.first
        expect(investigator.role).to eq("Investigator")
        expect(investigator.name).to eq("Investigator Name")
      
        # Test for FacilityContacts creation and attributes
        expect(facility.facility_contacts.size).to eq(1)
        contact = facility.facility_contacts.first
        expect(contact.contact_type).to eq("primary") # Assuming the first one is marked as primary
        expect(contact.name).to eq("Contact Name")
        expect(contact.email).to eq("contact@example.com")
        expect(contact.phone).to eq("123-456-7890")
        expect(contact.phone_extension).to be_nil # Assuming there's no phoneExt in the JSON for this contact
      end

    end
  end