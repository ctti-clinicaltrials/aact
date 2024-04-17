require 'rails_helper'

describe Outcome do
  it "should create an instance of Outcome", schema: :v2 do
    expected_data = [
      {
        "nct_id"=>"NCT000001",
        "outcome_type" => "Primary",
        "title" => "Number of Chewing Cycles Per Bolus",
        "param_type" => "Mean",
        "time_frame" => "Baseline (single timepoint only)",
        "description" => "Using surface electromyography (sEMG) of the masseter muscle, we will count the number of muscle contraction spikes (i.e. chewing cycles) seen for chewing activity for a single comfortable bite of each bolus type.",
        "units" => "number of chewing cycles",
        "dispersion_type" => "Standard Deviation",
        "population" => "Data for 3 additional participants could not be analyzed due to poor electromyography signal quality.",
        "anticipated_posting_date" => Date.parse("2024-08-01"),
        "anticipated_posting_month_year" =>  "2024-08",
        "units_analyzed" => "encounters"
      }
    ]

    # load the json
    content = JSON.parse(File.read('spec/support/json_data/outcome.json'))
    StudyJsonRecord.create(nct_id: "NCT000001", version: '2', content: content) # create a brand new json record

    # process the json
    StudyJsonRecord::Worker.new.process # import the new json record

    # load the database entries
    imported = Outcome.all.map { |x| x.attributes }
    imported.each { |x| x.delete("id") }
    
    # Compare the modified imported data with the expected data
    expect(imported).to eq(expected_data)
  end
end
