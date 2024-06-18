require 'rails_helper'

describe FacilityInvestigator do
  it "should create instances of FacilityInvestigator", schema: :v2 do
    expected_data = [
      {
        "nct_id" => "NCT000001",
        "name" => "Detlef Kindgen-Milles, Prof.",
        "role" => "PRINCIPAL_INVESTIGATOR"
      },
      {
        "nct_id" => "NCT000001",
        "name" => "Timo Brandenburger, PD Dr. med.",
        "role" => "SUB_INVESTIGATOR"
      },
      {
        "nct_id" => "NCT000001",
        "name" => "Thomas Dimski, Dr. med.",
        "role" => "SUB_INVESTIGATOR"
      }
    ]

    # Load the JSON
    content = JSON.parse(File.read('spec/support/json_data/facility_investigator.json'))

    # Create a new StudyJsonRecord with the provided content
    StudyJsonRecord.create(nct_id: "NCT000001", version: '2', content: content)

    # Process the JSON
    StudyJsonRecord::Worker.new.process

    # load the database entries
    imported = FacilityInvestigator.all.map { |x| x.attributes }
    imported.each { |x| x.delete('id'); x.delete('facility_id') }

    # Compare the modified imported data with the expected data
    expect(imported).to eq(expected_data)   
  end
end
