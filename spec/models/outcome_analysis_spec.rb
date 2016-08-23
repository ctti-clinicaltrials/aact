require 'rails_helper'

describe OutcomeAnalysis do
  it "should retain numbers after decimal in percent" do
    nct_id='NCT01642004'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create
    o=study.outcome_analyses.select{|x|x.p_value_description=='Stratified by region (US/Canada, Rest Of World (ROW), Europe) and prior treatment regimen (Paclitaxel, Another agent) as entered in the Interactive Voice Response System (IVRS).' and x.param_value==0.59}
    expect(o.size).to eq(1)
    expect(o.first.ci_percent).to eq(BigDecimal.new("96.85"))
  end

  it "study should be fine without any outcome analyses" do
    nct_id='NCT00023673'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create
    o=study.outcomes.select{|x|x.title=='Percentage of Patients Who Survive at Least 12 Months'}.first
    expect(o.outcome_analyses.size).to eq(0)
  end

  it "study should have expected outcomes" do
    #  This Study is good for testing OutcomeAnalysis - contains several rare attributes
    nct_id='NCT02028676'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create
    expect(study.outcomes.size).to eq(58)
    o=study.outcomes.select{|x|x.title=='LCM vs CDM: Disease Progression to a New WHO Stage 4 Event or Death'}.first

    expect(o.outcome_analyses.size).to eq(2)
    a=o.outcome_analyses.select{|x|x.method=='Comparison of poisson rates'}.first
    expect(a.non_inferiority).to eq('Yes')
    expect(a.non_inferiority_description).to eq('With assumptions detailed above, >90% power and one-sided alpha=0.05, 1160 children would be required to exclude an increase in progression rate of 1.6% from 2.5% to 4.1% per year in the CDM arm (upper 95% confidence limit of LCM: CDM hazard ratio 1.64).')
    expect(a.method).to eq('Comparison of poisson rates')
    expect(a.method_description).to eq('Statistical analysis plan specified that p-value was to be calculated from the log-rank test, so not provided for the risk difference')
    expect(a.p_value).to eq(0.43)
    expect(a.param_type).to eq('Risk Difference (RD)')
    expect(a.param_value).to eq(0.32)
    expect(a.ci_percent).to eq(95)
    expect(a.ci_n_sides).to eq('2-Sided')
    expect(a.ci_lower_limit).to eq(-0.47)
    expect(a.ci_upper_limit).to eq(1.12)
    expect(a.ci_upper_limit_na_comment).to eq('this is a ci upper limit comment')
    expect(a.estimate_description).to eq('Difference is CDM minus LCM')
    expect(a.groups_description.gsub(/\n/,' ')).to eq('Assumptions: control group (LCM) event rate 3% per year rates are reduced to 2% per year in the best of the induction-maintenance arms leading to an overall rate of progression to new WHO stage 4 or death of 2.5% recruitment is over 1.5 years and follow-up for a minimum further 3.5 years. cumulative loss to follow-up is 10% at 5 years. See below for rest of sample size as this box is not big enough.')
    expect(a.outcome_analysis_groups.size).to eq(2)
    o1_group=a.outcome_analysis_groups.select{|x|x.ctgov_group_code=='O1'}.first
    o2_group=a.outcome_analysis_groups.select{|x|x.ctgov_group_code=='O2'}.first

    expect(o1_group.nct_id).to eq(nct_id)
    expect(o1_group.ctgov_group_code).to eq('O1')
    expect(o1_group.result_group.ctgov_group_code).to eq('O1')
    expect(o1_group.result_group.title).to eq('Clinically Driven Monitoring (CDM)')

    expect(o2_group.ctgov_group_code).to eq('O2')
    expect(o2_group.result_group.ctgov_group_code).to eq('O2')
    expect(o2_group.result_group.title).to eq('Laboratory Plus Clinical Monitoring (LCM)')

    o=study.outcomes.select{|x|x.title=='Cotrimoxazole: Adherence to ART as Measured by Self-reported Questionnaire (Missing Any Pills in the Last 4 Weeks)'}.first
    expect(o.outcome_analyses.size).to eq(1)
    expect(o.outcome_analyses.first.p_value_description).to eq('Adjusted for randomization stratification factors')
  end

end
