require 'rails_helper'

RSpec.describe BrowseIntervention, type: :model do
  describe "BrowseIntervention mapping" do
    it "should map BrowseIntervention with mesh terms and types", schema: :v2 do
      # Load the json
      content = JSON.parse(File.read('spec/support/json_data/browse_intervention.json'))
      StudyJsonRecord.create(nct_id: "NCT000001", version: '2', content: content) # Create a brand new json record

      # Process the json
      StudyJsonRecord::Worker.new.process # Import the new json record

      # Load the database entries
      imported = BrowseIntervention.all.map { |x| x.attributes.except("id", "created_at", "updated_at") }

      expected_data = [
        { "nct_id" => "NCT000001", "mesh_term" => "Cyclophosphamide", "downcase_mesh_term" => "cyclophosphamide", "mesh_type" => "mesh-list" },
        { "nct_id" => "NCT000001", "mesh_term" => "Immunosuppressive Agents", "downcase_mesh_term" => "immunosuppressive agents", "mesh_type" => "mesh-ancestor" },
        { "nct_id" => "NCT000001", "mesh_term" => "Cyclophosphamide", "downcase_mesh_term" => "cyclophosphamide", "mesh_type" => "mesh-browseLeave" },
        { "nct_id" => "NCT000001", "mesh_term" => "Infe", "downcase_mesh_term" => "infe", "mesh_type" => "mesh-browseBranch" }
      ]

      expect(imported).to match_array(expected_data)
    end

  end
end
