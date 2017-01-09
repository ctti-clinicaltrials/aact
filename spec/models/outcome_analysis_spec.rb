require 'rails_helper'

describe OutcomeAnalysis do
  it "should have proper relationships and retain numbers after decimal in percent" do
    nct_id='NCT01642004'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create
    expect(study.outcomes.size).to eq(13)

    expect(study.outcomes.select{|x|x.outcome_type=='Other Pre-specified'}.size).to eq(1)
    o=study.outcomes.select{|x|x.outcome_type=='Other Pre-specified'}.first
    expect(o.outcome_groups.size).to eq(2)
    expect(o.measures.first.measurements.size).to eq(2)
    expect(o.measures.first.dispersion_type).to eq('95% Confidence Interval')
    expect(o.measures.first.param_type).to eq('Median')
    expect(o.analyses.first.groups.size).to eq(2)
    expect(o.title).to eq('Overall Survival (OS) Time in Months for All Randomized Participants at Updated Survival Follow-up')
    expect(o.time_frame).to eq('Randomization until July 2015, approximately 33 months')
    expect(o.safety_issue).to eq('No')
    expect(o.population).to eq('All randomized participants')

    oa_col=o.analyses.select{|x|x.p_value_description=='Stratified by region (US/Canada, Rest Of World (ROW), Europe) and prior treatment regimen (Paclitaxel, Another agent) as entered in the Interactive Voice Response System (IVRS).'}
    expect(oa_col.size).to eq(1)
    oa=oa_col.first
    expect(oa.param_value).to eq(0.62)
    expect(oa.ci_n_sides).to eq('2-Sided')
    expect(oa.non_inferiority).to eq('No')
    expect(oa.p_value).to eq(BigDecimal.new('0.0004'))
    expect(oa.ci_percent).to eq(BigDecimal.new("95"))
    expect(oa.ci_lower_limit).to eq(BigDecimal.new("0.47"))
    expect(oa.ci_upper_limit).to eq(BigDecimal.new("0.81"))
    expect(oa.estimate_description).to eq('Hazard Ratio (HR) = Nivolumab over Docetaxel')
    expect(oa.groups.size).to eq(2)
    expect(oa.groups.select{|x| x.ctgov_group_code=='O1'}.size).to eq(1)
    expect(oa.groups.select{|x| x.ctgov_group_code=='O2'}.size).to eq(1)
  end

  it "study should be fine without any outcome analyses" do
    nct_id='NCT00023673'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create
    o=study.outcomes.select{|x|x.title=='Percentage of Patients Who Survive at Least 12 Months'}.first
    expect(o.groups.size).to eq(1)
    expect(o.groups.first.ctgov_group_code).to eq('O1')
    expect(o.groups.first.title).to eq('Phase I/II: 74 Gy/37 fx + Chemotherapy')
    expect(o.groups.first.result_group.title).to eq('Phase I/II: 74 Gy/37 fx + Chemotherapy')
    expect(o.groups.first.result_group.result_type).to eq('Outcome')
    expect(o.outcome_analyses.size).to eq(0)
    expect(o.outcome_measures.size).to eq(1)
    expect(o.measures.size).to eq(1)
    expect(o.measures.first.measurements.size).to eq(1)
    m=o.measures.first.measurements.first
    expect(m.dispersion_lower_limit).to eq(61.5)
    expect(m.dispersion_upper_limit).to eq(85.0)
    expect(m.param_value_num).to eq(75.5)
    expect(m.ctgov_group_code).to eq('O1')
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
  end

end
