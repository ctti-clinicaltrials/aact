require 'rails_helper'

RSpec.describe OutcomeAnalysis, type: :model do
  it "should create an instance of OutcomeAnalysis", schema: :v2 do
    expected_data = [
      {
        "nct_id" => "NCT000001",
        "non_inferiority_type" => "OTHER",
        "non_inferiority_description" => "Weeks 8 and 24",
        "param_type" => "Odds Ratio (OR)",
        "param_value" => BigDecimal("15.231"),
        "p_value_modifier" => "<",
        "p_value" => 0.001,
        "p_value_raw" => "<0.001",
        "p_value_description" => "with significance level of 0.025",
        "ci_n_sides" => "TWO_SIDED",
        "ci_percent" => BigDecimal("95"),
        "ci_lower_limit" => BigDecimal("7.336"),
        "ci_upper_limit" =>  BigDecimal("31.623"),
        "ci_lower_limit_raw" => "7.336",
        "ci_upper_limit_raw" => "31.623",
        "ci_upper_limit_na_comment" => nil,
        "estimate_description" => nil,
        "dispersion_type" => nil,
        "dispersion_value" => nil,
        "method" => "Regression, Logistic",
        "method_description" => "Treatment and baseline pain categorical score were factors.",
        "groups_description" => "Odds ratio: CZP/Placebo and p-value were calculated using logistic regression with factors for treatment, region and Magnetic Resonance Imaging/C- Reactive Protein (MRI/CRP) classification.",
        "other_analysis_description" => nil
      },
      {
        "nct_id" => "NCT000001",
        "non_inferiority_type" => "OTHER",
        "non_inferiority_description" => "4 letter margin (1-sided)",
        "param_type" => "Odds Ratio (OR)",
        "param_value" => BigDecimal("7.436"),
        "p_value_modifier" => "<",
        "p_value" => 0.001,
        "p_value_raw" => "<0.001",
        "p_value_description" => nil,
        "ci_n_sides" => "TWO_SIDED",
        "ci_percent" => BigDecimal("95"),
        "ci_lower_limit" => BigDecimal("4.127"),
        "ci_upper_limit" => BigDecimal("13.401"),
        "ci_lower_limit_raw" => "4.127",
        "ci_upper_limit_raw" => "13.401",
        "ci_upper_limit_na_comment" => "Due to smaller number of participants with an event, upper limit of 95% CI could not be calculated.",
        "dispersion_type" => "STANDARD_ERROR_OF_MEAN",
        "dispersion_value" => BigDecimal("0.73"),
        "estimate_description" => "Hazard ratio and its CIs were estimated from Cox Proportional hazards model stratified by FLIPI2 risk categorization.",
        "method" => "Regression, Logistic",
        "method_description" => nil,
        "groups_description" => "Odds ratio: CZP/Placebo and p-value were calculated using logistic regression with factors for treatment, region and MRI/CRP classification.",
        "other_analysis_description" => "The mean difference is actually adjusted mean of difference and the dispersion value is standard error of differences."
      },
      {
        # [
        #   {
            "nct_id" => "NCT000001",
            "non_inferiority_type" => "OTHER",
            "non_inferiority_description" => nil,
            "param_type" => "Odds Ratio (OR)",
            "param_value" => BigDecimal("7.359"),
            "p_value_modifier" => "<",
            "p_value" => 0.001,
            "p_value_raw" => "<0.001",
            "p_value_description" => "p-value for treatment difference",
            "ci_n_sides" => "TWO_SIDED",
            "ci_percent" => BigDecimal("95"),
            "ci_lower_limit" => BigDecimal("4.286"),
            "ci_upper_limit" => BigDecimal("12.636"),
            "ci_lower_limit_raw" => "4.286",
            "ci_upper_limit_raw" => "12.636",
            "ci_upper_limit_na_comment" => nil,
            "estimate_description" => nil,
            "dispersion_type" => nil,
            "dispersion_value" => nil,
            "method" => "Regression, Logistic",
            "method_description" => "A log-rank test stratified by FLIPI2 risk was used to compare the treatment groups with respect to PFS at a 2-sided alpha level of 0.05.",
            "groups_description" => "Odds ratio: CZP/Placebo and p-value were calculated using logistic regression with factors for treatment, region MRI/CRP classification.",
            "other_analysis_description" => nil
          },
          {
            "nct_id" => "NCT000001",
            "non_inferiority_type" => "SUPERIORITY",
            "non_inferiority_description" => "Week 64",
            "param_type" => "LS Mean Difference",
            "param_value" => BigDecimal("-1.1"),
            "p_value_modifier" => "",
            "p_value" => 0.331,
            "p_value_raw" => "0.331",
            "p_value_description" => nil,
            "ci_n_sides" => "TWO_SIDED",
            "ci_percent" => BigDecimal("95"),
            "ci_lower_limit" => BigDecimal("-3.4"),
            "ci_upper_limit" => BigDecimal("1.2"),
            "ci_lower_limit_raw" => "-3.4",
            "ci_upper_limit_raw" => "1.2",
            "method" => "ANCOVA"
          # }
        # ]
      },
      {
        "nct_id" => "NCT000001",
        "non_inferiority_type" => "OTHER",
        "non_inferiority_description" => "Week 18",
        "param_type" => "Difference",
        "param_value" => BigDecimal("-1.696"),
        "p_value_modifier" => "<",
        "p_value" => 0.001,
        "p_value_raw" => "<0.001",
        "p_value_description" => nil,
        "ci_n_sides" => "TWO_SIDED",
        "ci_percent" => BigDecimal("95"),
        "ci_lower_limit" => BigDecimal("-2.110"),
        "ci_upper_limit" => BigDecimal("-1.282"),
        "ci_lower_limit_raw" => "-2.110",
        "ci_upper_limit_raw" => "-1.282",
        "ci_upper_limit_na_comment" => "Upper limit of the confidence interval is not reached due to censoring rate.",
        "estimate_description" => "The Kaplan Meier method was used to estimate median OS(in months). The Greenwood method was used to estimate confidence limits of median overall survival.",
        "method" => "ANCOVA",
        "method_description" => "Treatment and baseline pain categorical score were factors.",
        "groups_description" => "From an ANCOVA model including scores at Baseline, treatment group, region and MRI/CRP classification.",
        "other_analysis_description" => "Hazard Ratio (HR) (Dex/PBO)"
      },
      {
        # [
        #   {
            "nct_id" => "NCT000001",
            "non_inferiority_type" => "OTHER",
            "non_inferiority_description" => "Week 13",
            "param_type" => "Difference",
            "param_value" => BigDecimal("-1.585"),
            "p_value_modifier" => "<",
            "p_value" => 0.001,
            "p_value_raw" => "<0.001",
            "p_value_description" => nil,
            "ci_n_sides" => "TWO_SIDED",
            "ci_percent" => BigDecimal("95"),
            "ci_lower_limit" => BigDecimal("-2.132"),
            "ci_upper_limit" => BigDecimal("-1.038"),
            "ci_lower_limit_raw" => "-2.132",
            "ci_upper_limit_raw" => "-1.038",
            "dispersion_type" => "STANDARD_ERROR_OF_MEAN",
            "dispersion_value" => "9.87",
            "method" => "ANCOVA",
            "groups_description" => "From an ANCOVA model including scores at Baseline, treatment group, region and MRI/CRP classification."
          },
          {
            "nct_id" => "NCT000001",
            "non_inferiority_type" => "SUPERIORITY",
            "non_inferiority_description" => "Week 16",
            "param_type" => "Odds Ratio (OR)",
            "param_value" => BigDecimal("2.6"),
            "p_value_modifier" => "",
            "p_value" => 0.0001,
            "p_value_raw" => "<0.0001",
            "p_value_description" => nil,
            "ci_n_sides" => "TWO_SIDED",
            "ci_percent" => BigDecimal("95"),
            "ci_lower_limit" => BigDecimal("1.7"),
            "ci_upper_limit" => BigDecimal("3.9"),
            "ci_lower_limit_raw" => "1.7",
            "ci_upper_limit_raw" => "3.9",
            "dispersion_type" => "STANDARD_ERROR_OF_MEAN",
            "dispersion_value" => "11.26",
            "method" => "likelihood ratio test",
            "method_description" => "Assessed at one-sided 0.025 significance level"
        #   }
        # ]
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
