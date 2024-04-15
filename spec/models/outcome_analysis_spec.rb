require 'rails_helper'

RSpec.describe OutcomeAnalysis, type: :model do
  it "should create an instance of OutcomeAnalysis", schema: :v2 do
    expected_data = [
      {
        "nct_id" => "NCT000001",
        "non_inferiority_type" => "OTHER",
        "non_inferiority_description" => "Weeks 8 and 24",
        "param_type" => "Odds Ratio (OR)",
        "param_value" => "15.231",
        "p_value_modifier" => "<0.001",
        "p_value" => "<0.001",
        "p_value_raw" => "<0.001",
        "ci_n_sides" => "TWO_SIDED",
        "ci_percent" => "95",
        "ci_lower_limit" => "7.336",
        "ci_upper_limit" => "31.623",
        "ci_lower_limit_raw" => "7.336",
        "ci_upper_limit_raw" => "31.623",
        "method" => "Regression, Logistic",
        "method_description" => "Treatment and baseline pain categorical score were factors.",
        "groups_description" => "Odds ratio: CZP/Placebo and p-value were calculated using logistic regression with factors for treatment, region and Magnetic Resonance Imaging/C- Reactive Protein (MRI/CRP) classification."
      }
    ]  

    # load the json
    content = JSON.parse(File.read('spec/support/json_data/outcome_analysis.json'))
    StudyJsonRecord.create(nct_id: "NCT000001", version: '2', content: content) # create a brand new json record

    # process the json
    StudyJsonRecord::Worker.new.process # import the new json record

    # load the database entries
    imported = OutcomeAnalysis.all.map{ |x| x.attributes.except("id", "outcome_id") }

    # Compare the modified imported data with the expected data
    expect(imported).to eq(expected_data)
  end
end
