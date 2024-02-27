require 'rails_helper'

RSpec.describe BrowseCondition, type: :model do
  describe "BrowseCondition mapping" do
    it "should map BrowseCondition with mesh terms and types" schema: :v2 do
      # Load the json
      content = JSON.parse(File.read('spec/support/json_data/browse_condition.json'))
      StudyJsonRecord.create(nct_id: "NCT000002", version: '2', content: content) # Create a brand new json record
      
      # Process the json
      StudyJsonRecord::Worker.new.process # Import the new json record
  
      # Load the database entries
      imported = BrowseCondition.all.map { |x| x.attributes.except("id", "created_at", "updated_at") }
      
      expected_data = [
        { "nct_id" => "NCT000002", "mesh_term" => "Lung Neoplasms", "downcase_mesh_term" => "lung neoplasms", "mesh_type" => "mesh-list" },
        { "nct_id" => "NCT000002", "mesh_term" => "Carcinoma, Non-Small-Cell Lung", "downcase_mesh_term" => "carcinoma, non-small-cell lung", "mesh_type" => "mesh-list" },
        { "nct_id" => "NCT000002", "mesh_term" => "Respiratory Tract Neoplasms", "downcase_mesh_term" => "respiratory tract neoplasms", "mesh_type" => "mesh-ancestor" },
        { "nct_id" => "NCT000002", "mesh_term" => "Thoracic Neoplasms", "downcase_mesh_term" => "thoracic neoplasms", "mesh_type" => "mesh-ancestor" },
        { "nct_id" => "NCT000002", "mesh_term" => "Neoplasms by Site", "downcase_mesh_term" => "neoplasms by site", "mesh_type" => "mesh-ancestor" },
        { "nct_id" => "NCT000002", "mesh_term" => "Neoplasms", "downcase_mesh_term" => "neoplasms", "mesh_type" => "mesh-ancestor" },
        { "nct_id" => "NCT000002", "mesh_term" => "Lung Diseases", "downcase_mesh_term" => "lung diseases", "mesh_type" => "mesh-ancestor" },
        { "nct_id" => "NCT000002", "mesh_term" => "Respiratory Tract Diseases", "downcase_mesh_term" => "respiratory tract diseases", "mesh_type" => "mesh-ancestor" },
        { "nct_id" => "NCT000002", "mesh_term" => "Carcinoma, Bronchogenic", "downcase_mesh_term" => "carcinoma, bronchogenic", "mesh_type" => "mesh-ancestor" },
        { "nct_id" => "NCT000002", "mesh_term" => "Bronchial Neoplasms", "downcase_mesh_term" => "bronchial neoplasms", "mesh_type" => "mesh-ancestor" }
      ]
  
      expect(imported).to match_array(expected_data)
    end

     
  end
end




