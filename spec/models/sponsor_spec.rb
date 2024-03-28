require 'rails_helper'

RSpec.describe Sponsor do

  it 'should create an instance of Sponsor and return Lead and Collaborator sponsor types', schema: :v2 do
    expected_data = [
      { 
        "nct_id" => "NCT000001", 
        "agency_class" => "INDIV", 
        "lead_or_collaborator" => "lead",
        "name" => "Arbelaez, Ana Maria"
      },
      { 
        "nct_id" => "NCT000001", 
        "agency_class" => "NIH", 
        "lead_or_collaborator" => "collaborator",
        "name" => "National Institute of Diabetes and Digestive and Kidney Diseases (NIDDK)" 
      },
      { 
        "nct_id" => "NCT000001", 
        "agency_class" => "NIH", 
        "lead_or_collaborator" => "collaborator",
        "name" => "National Institutes of Health (NIH)"
      },
      { 
        "nct_id" => "NCT000001", 
        "agency_class" => "INDUSTRY", 
        "lead_or_collaborator" => "collaborator",
        "name" => "Novo Nordisk A/S" 
      },
      { 
        "nct_id" => "NCT000001", 
        "agency_class" => "OTHER", 
        "lead_or_collaborator" => "collaborator",
        "name" => "Washington University School of Medicine"
      }
    ]  

    # load the json
    content = JSON.parse(File.read('spec/support/json_data/sponsor_1.json'))
    StudyJsonRecord.create(nct_id: "NCT000001", version: '2', content: content) # create a brand new json record

    # process the json
    StudyJsonRecord::Worker.new.process # import the new json record

    # load the database entries
    imported = Sponsor.all.order(name: :asc).map { |x| x.attributes }
    imported.each { |x| x.delete("id") }

   # Compare the modified imported data with the expected data
    expect(imported).to eq(expected_data)
  end

  it 'should create an instance of Sponsor and return Lead sponsor type and no Collaborator sponsor type', schema: :v2 do
    expected_data = [
      { 
        "nct_id" => "NCT000001", 
        "agency_class" => "INDUSTRY", 
        "lead_or_collaborator" => "lead",
        "name" => "UCB BIOSCIENCES GmbH"
      }
    ]

    # load the json
    content = JSON.parse(File.read('spec/support/json_data/sponsor_2.json'))
    StudyJsonRecord.create(nct_id: "NCT000001", version: '2', content: content) # create a brand new json record

    # process the json
    StudyJsonRecord::Worker.new.process # import the new json record

    # load the database entries
    imported = Sponsor.all.order(name: :asc).map { |x| x.attributes }
    imported.each { |x| x.delete("id") }

   # Compare the modified imported data with the expected data
    expect(imported).to eq(expected_data)
  end

end