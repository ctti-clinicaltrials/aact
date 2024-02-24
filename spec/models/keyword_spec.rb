require 'rails_helper'

describe Keyword do
  it "should create an instance of Keyword" do
    expected_data = [
      { "nct_id" => "NCT000001", "name" => "Axial Spondyloarthritis", "downcase_name" => "axial spondyloarthritis".downcase },
      { "nct_id" => "NCT000001", "name" => "axSpA", "downcase_name" => "axSpA".downcase },
      { "nct_id" => "NCT000001", "name" => "Ankylosing Spondylitis", "downcase_name" => "ankylosing spondylitis".downcase },
      { "nct_id" => "NCT000001", "name" => "Anti TNF-alpha", "downcase_name" => "anti TNF-alpha".downcase },
      { "nct_id" => "NCT000001", "name" => "Certolizumab Pegol", "downcase_name" => "certolizumab pegol".downcase },
      { "nct_id" => "NCT000001", "name" => "Nr-axSpA", "downcase_name" => "Nr-axSpA".downcase },
      { "nct_id" => "NCT000001", "name" => "Non-radiographic", "downcase_name" => "non-radiographic".downcase },
      { "nct_id" => "NCT000001", "name" => "Spondylarthropathies", "downcase_name" => "spondylarthropathies".downcase },
      { "nct_id" => "NCT000001", "name" => "Arthritis", "downcase_name" => "arthritis".downcase },
      { "nct_id" => "NCT000001", "name" => "Spinal Diseases", "downcase_name" => "spinal diseases".downcase },
      { "nct_id" => "NCT000001", "name" => "Immunosuppressive Agents", "downcase_name" => "immunosuppressive agents".downcase }
    ]
      
    # Load the JSON
    content = JSON.parse(File.read('spec/support/json_data/keyword.json'))
    StudyJsonRecord.create(nct_id: "NCT000001", version: '2', content: content) # Create a brand new JSON record

    # Process the JSON
    StudyJsonRecord::Worker.new.process # Import the new JSON record

    # Load the database entries
    imported = Keyword.all.map { |x| x.attributes }
    imported.each { |x| x.delete("id") }

    # Compare the modified imported data with the expected data
    expect(imported).to eq(expected_data)   
  end
end
