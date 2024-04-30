require 'rails_helper'

describe OutcomeMeasurement do
  it "should create an instance of OutcomeMeasurement", schema: :v2 do
    expected_data = [
      {
        nct_id: 'NCT000001',
        ctgov_group_code: 'OG000',
        classification: 'Class Title',
        category: 'Category Title',
        title: 'Absolute Change in Pre-Bronchodilator Forced Expiratory Volume in 1 Second (FEV1)',
        description: "FEV1 measures how much air a person can exhale during the first second of a forced breath.\n\nAdjusted means are reported.", 
        units: "Milliliters (mL)",
        param_type: "MEAN",
        dispersion_type: "95% Confidence Interval",
        param_value: "12",
        param_value_num: BigDecimal(12),
        dispersion_value: "2",
        dispersion_value_num: BigDecimal(2),
        dispersion_lower_limit: BigDecimal(8),
        dispersion_upper_limit: BigDecimal(16),
        dispersion_lower_limit_raw: "8",
        dispersion_upper_limit_raw:"16",
        explanation_of_na: "Not applicable"
      },
      {
        nct_id: 'NCT000001',
        ctgov_group_code: 'OG001',
        classification: 'Class Title 0G001 and 0G002',
        category: 'Category Title 0G001 and 0G002',
        title: 'Overall Response Rate (ORR): Percentage of Participants With Overall Response (OR) at Week 26',
        description: "ORR was defined as the percentage of participants who achieved complete response (CR) or partial response (PR) in accordance with the revised response criteria for malignant lymphoma (Cheson 2007)...", 
        units: "percentage of participants",
        param_type: "NUMBER",
        dispersion_type: "95% Confidence Interval",
        param_value: "70.7",
        param_value_num: BigDecimal("70.7"),
        dispersion_value: "4",
        dispersion_value_num: BigDecimal(4),
        dispersion_lower_limit: BigDecimal("63.8"),
        dispersion_upper_limit: BigDecimal("76.9"),
        dispersion_lower_limit_raw: "63.8",
        dispersion_upper_limit_raw:"76.9",
        explanation_of_na: "Comment 0G001"
      },
      {
        nct_id: 'NCT000001',
        ctgov_group_code: 'OG002',
        classification: 'Class Title 0G001 and 0G002',
        category: 'Category Title 0G001 and 0G002',
        title: 'Overall Response Rate (ORR): Percentage of Participants With Overall Response (OR) at Week 26',
        description: "ORR was defined as the percentage of participants who achieved complete response (CR) or partial response (PR) in accordance with the revised response criteria for malignant lymphoma (Cheson 2007)...", 
        units: "percentage of participants",
        param_type: "NUMBER",
        dispersion_type: "95% Confidence Interval",
        param_value: "75.5",
        param_value_num: BigDecimal("75.5"),
        dispersion_value: "6",
        dispersion_value_num: BigDecimal(6),
        dispersion_lower_limit: BigDecimal("68.9"),
        dispersion_upper_limit: BigDecimal("81.4"),
        dispersion_lower_limit_raw: "68.9",
        dispersion_upper_limit_raw:"81.4",
        explanation_of_na: "Comment 0G002"
      }  
    ]
    # load the json
    content = JSON.parse(File.read('spec/support/json_data/outcome_measurement.json'))
    StudyJsonRecord.create(nct_id: "NCT000001", version: '2', content: content) # create a brand new json record

    # process the json
    StudyJsonRecord::Worker.new.process # import the new json record

    # load the database entries
    imported = OutcomeMeasurement.all.map do |x|
      {
        nct_id: x.nct_id,
    # outcome_id integer,
    # result_group_id integer,
        ctgov_group_code: x.ctgov_group_code,
        classification: x.classification,
        category: x.category,
        title: x.title,
        description: x.description,
        units: x.units,
        param_type: x.param_type,
        dispersion_type: x.dispersion_type,
        param_value: x.param_value,
        param_value_num: x.param_value_num,
        dispersion_value: x.dispersion_value,
        dispersion_value_num: x.dispersion_value_num,
        dispersion_lower_limit: x.dispersion_lower_limit,
        dispersion_upper_limit: x.dispersion_upper_limit,
        dispersion_lower_limit_raw: x.dispersion_lower_limit_raw,
        dispersion_upper_limit_raw: x.dispersion_upper_limit_raw,
        explanation_of_na: x.explanation_of_na,
      }
    end
  
    # Compare the modified imported data with the expected data
    expect(imported).to eq(expected_data)
  end
end
