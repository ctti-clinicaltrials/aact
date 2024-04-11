require 'rails_helper'

describe 'ReportedEventTotal' do
  it "should create instances of ReportedEventTotal from JSON", schema: :v2 do

  expected_data = [
    {
      "nct_id" => "NCT000001",
      "ctgov_group_code" => "EG000",
      "event_type" => "deaths",
      "classification" => "Total, all-cause mortality",
      "subjects_affected" => 0,
      "subjects_at_risk" => 20
    },
    {
      "nct_id" => "NCT000001",
      "ctgov_group_code" => "EG000",
      "event_type" => "other",
      "classification" => "Total, other adverse events",
      "subjects_affected" => 8,
      "subjects_at_risk" => 20
    },
    {
      "nct_id" => "NCT000001",
      "ctgov_group_code" => "EG000",
      "event_type" => "serious",
      "classification" => "Total, serious adverse events",
      "subjects_affected" => 0,
      "subjects_at_risk" => 20
    },
    {
      "nct_id" => "NCT000001",
      "ctgov_group_code" => "EG001",
      "event_type" => "deaths",
      "classification" => "Total, all-cause mortality",
      "subjects_affected" => 0,
      "subjects_at_risk" => 4
    },
    {
      "nct_id" => "NCT000001",
      "ctgov_group_code" => "EG001",
      "event_type" => "other",
      "classification" => "Total, other adverse events",
      "subjects_affected" => 4,
      "subjects_at_risk" => 4
    },
    {
      "nct_id" => "NCT000001",
      "ctgov_group_code" => "EG001",
      "event_type" => "serious",
      "classification" => "Total, serious adverse events",
      "subjects_affected" => 0,
      "subjects_at_risk" => 4
    }
  ]

    # load json
    content = JSON.parse(File.read('spec/support/json_data/reported_event_total.json'))
  
    # Create a brand new JSON record
    StudyJsonRecord.create(nct_id: 'NCT000001', version: '2', content: content)

    # Import the new JSON record
    StudyJsonRecord::Worker.new.process

    # Load the database entries
    imported = ReportedEventTotal.all.order(:nct_id, :ctgov_group_code, :event_type).map do |x| 
      x.attributes
    end

    # Remove the unwanted keys
    imported.each do |x|
      x.delete("id")
      x.delete("created_at")
      x.delete("updated_at")
    end

    expect(imported).to eq(expected_data)
  end
end