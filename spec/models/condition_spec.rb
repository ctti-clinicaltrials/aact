require 'rails_helper'

describe Condition do
  it "should create an instance of Condition", schema: :v2 do
    expected_data = [
      {
        "nct_id" => "NCT001",
        "name" => "Axial Spondyloarthritis",
        "downcase_name" => "axial spondyloarthritis"
      },
      {
        "nct_id" => "NCT001",
        "name" => "Nonradiographic Axial Spondyloarthritis",
        "downcase_name" => "nonradiographic axial spondyloarthritis"
      },
      {
        "nct_id" => "NCT001",
        "name" => "Nr-axSpA",
        "downcase_name" => "nr-axspa"
      }
    ]  

    setup_json_sample(described_class, models_support_path)
    imported = imported_data_for(described_class)
    expect(imported).to eq(expected_data)
  end
end

