require "rails_helper"
  
RSpec.describe IdInformation, type: :model do
  describe "Mapping" do
    let(:nct_id) { "NCT000001" }

    let(:content) { load_json(described_class) }
    let(:expected_data) do
      [
        { "nct_id" => "NCT000001", "id_source" => "nct_alias", "id_value" => "NCT000002", "id_type" => nil, "id_type_description" => nil, "id_link" => nil },
        { "nct_id" => "NCT000001", "id_source" => "org_study_id", "id_value" => "NRG-GY032", "id_type" => nil, "id_type_description" => nil, "id_link" => nil },
        { "nct_id" => "NCT000001", "id_source" => "secondary_id", "id_value" => "NCI-2023-09355", "id_type" => "REGISTRY", "id_type_description" => "CTRP", "id_link" => nil },
        { "nct_id" => "NCT000001", "id_source" => "secondary_id", "id_value" => "U10CA180868", "id_type" => "NIH", "id_type_description" => nil, "id_link" => "https://reporter.nih.gov/quickSearch/U10CA180868" },
      ]
    end

    before do
      StudyJsonRecord.create(nct_id: nct_id, version: "2", content: content)
      StudyJsonRecord::Worker.new.process_study(nct_id)
    end


    it "creates an instance of IdInformation", schema: :v2 do
      imported = IdInformation.all.order(id_source: :asc).map{|x| x.attributes }
      imported.each{|x| x.delete("id")}
      expect(imported).to eq(expected_data)
    end
  end
end